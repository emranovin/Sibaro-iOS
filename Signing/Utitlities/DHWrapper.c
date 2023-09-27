//
//  DHWrapper.c
//  Sibaro
//
//  Created by Emran Novin on 9/27/23.
//

#include "DHWrapper.h"
#include <openssl/dh.h>
#include <openssl/pem.h>
#include <openssl/bn.h>
#include <string.h>

DHKeyPair generate_dh_keypair(void) {
    DH* dh = DH_new();
    DH_generate_parameters_ex(dh, 2048, DH_GENERATOR_2, NULL);
    DH_generate_key(dh);

    // Serialize private key (DH parameters)
    BIO* privateBio = BIO_new(BIO_s_mem());
    PEM_write_bio_DHparams(privateBio, dh);
    long privateLen = BIO_pending(privateBio);
    char* private_key = (char*)malloc(privateLen + 1);
    BIO_read(privateBio, private_key, (int)privateLen);
    private_key[privateLen] = 0;

    // Serialize public key as a big integer
    const BIGNUM *pub_key, *priv_key;
    DH_get0_key(dh, &pub_key, &priv_key);
    
    int pub_key_len = BN_num_bytes(pub_key);
    char* public_key_buf = (char*)malloc(pub_key_len);
    BN_bn2bin(pub_key, (unsigned char*)public_key_buf);
    
    char* public_key = (char*)malloc(pub_key_len * 2 + 1); // Hex representation
    for(int i = 0; i < pub_key_len; i++) {
        sprintf(public_key + (i * 2), "%02x", public_key_buf[i]);
    }
    public_key[pub_key_len * 2] = 0;

    DHKeyPair result = { public_key, private_key };

    free(public_key_buf);
    BIO_free(privateBio);
    DH_free(dh);

    return result;
}
