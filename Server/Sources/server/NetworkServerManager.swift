//
//  NetworkServerManager.swift
//  Server
//
//  Created by Cheng Sun on 4/18/19.
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

class NetworkServerManager {
    
    fileprivate var server: HTTPServer
    
    internal init(root: String, port: UInt16, routerArr: Array<Dictionary<String, Any>>) {
        
        server = HTTPServer.init() // 创建httpServer服务器
        
        for dict: Dictionary in routerArr {
            let baseUri: String = dict["url"] as! String  //跟地址
            let method: String = dict["method"] as! String // 方法
            var routes = Routes.init(baseUri: baseUri) //创建路由
            let httpMethod = HTTPMethod.from(string: method)  // request method
            configure(routes: &routes, method: httpMethod)     //注册路由
            server.addRoutes(routes)                           //路由添加进服务
        }
        
        server.serverName = "127.0.0.1" //服务器name ip
        server.serverPort = port //端口号
        server.documentRoot = root //跟目录
        server.setResponseFilters([(Filter404(), .high)])  //404过滤
    }
    
    // MARK: 开启服务
    open func startServer() {
        do {
            try server.start()
        } catch PerfectError.networkError(let err, let msg) {
            print("网络出现错误：\(err) \(msg)")
        }catch {
            print("network unknow error")
        }
    }
    
    //MARK: 注册路由
    fileprivate func configure(routes: inout Routes, method: HTTPMethod) {
        routes.add(method: .post, uri: "/login", handler: handler)
        routes.add(method: .post, uri: "/profile", handler: handler)
        routes.add(method: .get, uri: "/photo", handler: handler)
    }
 
    // MARK: handler block
    func handler(request: HTTPRequest, response: HTTPResponse) {
        
        let queryParams = request.queryParams
        // 获得当前的请求路径
        let path = request.path
        print("path =" + "\(path)")

        switch path {
        case "/api/login": do {
            var name: String?
            var pwd: String?

            if let item1 = request.param(name: "username") {
                name = item1
            }
            if let item2 = request.param(name: "pwd") {
                pwd = item2
            }
            
            if name == "Genie" && pwd == "123456" {
                let d: [String:Any] = ["token": "193725"]
                
                do {
                    try response.setBody(string: self.baseResponseBodyJSONData(code: 200, message: "成功", data: d))
                } catch {
                    //...
                }
                response.completed()
            }
        }
        case "/api/profile": do {
            if let to = request.param(name: "token") {
                if to == "193725" {
                    // right now
                    // go get profile
                    
                    
                    let result = DataBaseManager().mysqlGetHomeDataResult()

                    do {
                        try response.setBody(string: self.baseResponseBodyJSONData(code: 200, message: "成功", data: result))

                    } catch {
                        //...
                    }
                }
            }
            response.completed()
            }
        case "/api/photo": do {
            if let path = request.param(name: "path") {

            do {
                let mrPebbles = File(path)
                let imageSize = mrPebbles.size
                let imageBytes = try mrPebbles.readSomeBytes(count: imageSize)
                
                response.setHeader(.contentType, value: MimeType.forExtension("jpg"))
                response.setHeader(.contentLength, value: "\(imageBytes.count)")
                response.setBody(bytes: imageBytes)
            } catch {
                response.status = .internalServerError
                response.setBody(string: "请求处理出现错误： \(error)")
            }
            }
            response.completed()
            }
        default:
            break
        }
    }

    //MARK: 通用响应格式
    func baseResponseBodyJSONData(code: Int, message: String, data: Any!) -> String {
        var result = Dictionary<String, Any>()
        result.updateValue(code, forKey: "code")
        result.updateValue(message, forKey: "message")
        if (data != nil) {
            result.updateValue(data as Any, forKey: "data")
        }else{
            result.updateValue("", forKey: "data")
        }
        guard let jsonString = try? result.jsonEncodedString() else {
            return ""
        }
        return jsonString
    }
    
    //MARK: 404过滤
    struct Filter404: HTTPResponseFilter {
        func filterBody(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
            callback(.continue)
        }
        func filterHeaders(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
            if case .notFound = response.status {
                response.setBody(string: "404 文件\(response.request.path)不存在。")
                response.setHeader(.contentLength, value: "\(response.bodyBytes.count)")
                callback(.done)
            } else {
                callback(.continue)
            }
        }
    }
}
