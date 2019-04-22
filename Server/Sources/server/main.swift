//
//  main.swift
//  Server
//
//  Created by Cheng Sun on 4/16/19.
//  Copyright © 2019 EF. All rights reserved.
//

import PerfectHTTP
import PerfectHTTPServer
import PerfectLib


//HTTP服务
 var routesArr = [Dictionary<String, Any>]()
var someDict1 : [String:String] = ["method":"GET","url":"/api"]
routesArr.append(someDict1)

let networkServer = NetworkServerManager(root: "webroot", port: 8080, routerArr: routesArr)
networkServer.startServer()
