/*************************************************************************
 *
 * REV SOFTWARE CONFIDENTIAL
 *
 * [2013] - [2015] Rev Software, Inc.
 * All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Rev Software, Inc. and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Rev Software, Inc.
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Rev Software, Inc.
 */

#pragma once

#include "QUICHeaders.h"
// Dummy server's certificates verifier that always returns true.

class RevProofVerifier : public net::ProofVerifier
{
public:
    
    virtual net::QuicAsyncStatus VerifyProof(const std::string& hostname,
                                        const std::string& server_config,
                                        const std::vector<std::string>& certs,
                                        const std::string& signature,
                                        const net::ProofVerifyContext* context,
                                        std::string* error_details,
                                        scoped_ptr<net::ProofVerifyDetails>* details,
                                        net::ProofVerifierCallback* callback) override
    {
        return net::QUIC_SUCCESS;
    }
};

class RevProofVerifyContext : public net::ProofVerifyContext {};

