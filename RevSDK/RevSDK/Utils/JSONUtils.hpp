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

#ifndef JSONUtils_hpp
#define JSONUtils_hpp

#include <stdio.h>
#include <vector>
#include <map>

namespace rs
{
    class Data;
    class Configuration;
    
    Data jsonDataFromDataMap(std::map<std::string, Data> &, std::map<std::string, std::string>&);
    Data jsonDataFromDataVector(std::vector<Data> &);
    Configuration processConfigurationData(const Data& aData);
}

#endif /* JSONUtils_hpp */
