//
//  QUICConnection.hpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/17/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef QUICConnection_hpp
#define QUICConnection_hpp

#include <stdio.h>

#include "Connection.hpp"

namespace rs {

class QUICConnection : public Connection
{
   public:
    void startWithRequest(std::shared_ptr<Request>, ConnectionDelegate*);
};
    
}

#endif /* QUICConnection_hpp */
