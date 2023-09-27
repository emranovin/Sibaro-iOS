//
//  DHWrapper.h
//  Sibaro
//
//  Created by Emran Novin on 9/27/23.
//

#ifndef DHWrapper_h
#define DHWrapper_h

typedef struct {
    char* public_key;
    char* private_key;
} DHKeyPair;

DHKeyPair generate_dh_keypair(void);

#endif /* DHWrapper_h */
