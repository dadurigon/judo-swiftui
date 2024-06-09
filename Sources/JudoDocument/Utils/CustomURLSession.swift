//
//  File.swift
//  
//
//  Created by Dion Durigon on 2024-06-09.
//

import Foundation

public class CustomURLSession: URLSession {
    
    public static override var shared: URLSession {
        let config = URLSessionConfiguration.ephemeral
        let delegate = SessionDelegate()
        return URLSession(configuration: config, delegate: delegate, delegateQueue: nil)
    }
}

public class SessionDelegate: NSObject, URLSessionDelegate {
    
    // Bypass any challenge
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            return completionHandler(URLSession.AuthChallengeDisposition.useCredential, nil)
        }
        return completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: serverTrust))
    }
    
    // Bypass any challenge
    public func urlSession(_: URLSession, task _: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            return completionHandler(URLSession.AuthChallengeDisposition.useCredential, nil)
        }
        return completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: serverTrust))
    }
}
