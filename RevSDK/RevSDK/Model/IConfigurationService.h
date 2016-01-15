/*************************************************************************
 *
 * REV SOFTWARE CONFIDENTIAL
 *
 * [2013] - [2016] Rev Software, Inc.
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

namespace rs
{
    class Configuration;
    
    class IConfigurationService
    {
    public:
        virtual ~IConfigurationService() = default;
        
        virtual void setOperationMode(RSOperationModeInner aMode) = 0;
        
        virtual void init() = 0;
        
        virtual void stopUpdate() = 0;
        virtual void resumeUpdate() = 0;
        
        virtual bool isStale() const { return false; }
        
        virtual std::shared_ptr<const Configuration> getActive() = 0;
    };
}
