//
//  GoogleIdentityToken.swift
//  HabitHuddle-Backend
//
//  Created by Kirill on 18.05.25.
//

import Vapor
import JWT

struct GoogleIdentityToken: JWTPayload {
    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case email = "email"
        case expiration = "exp"
        case issuer = "iss"
        case audience = "aud"
    }

    var subject: SubjectClaim
    var email: String
    var expiration: ExpirationClaim
    var issuer: IssuerClaim
    var audience: AudienceClaim

    func verify(using signer: JWTSigner) throws {
        try expiration.verifyNotExpired()
        guard issuer.value == "https://accounts.google.com" else {
            throw JWTError.claimVerificationFailure(name: "iss", reason: "Invalid issuer")
        }
    }
}
