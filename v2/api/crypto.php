<?php

    // Configuration settings for the key
    $config = array(
        "digest_alg" => "sha512",
        "private_key_bits" => 4096,
        "private_key_type" => OPENSSL_KEYTYPE_RSA,
    );
    
    // Create the private and public key
    $res = openssl_pkey_new($config);
    
    // Extract the private key into $private_key
    openssl_pkey_export($res, $private_key);
    
    // Extract the public key into $public_key
    $public_key = openssl_pkey_get_details($res);
    $public_key = $public_key["key"];
    
    // Something to encrypt
    $text = 'This is the text to encrypt';
    
    echo "This is the original text: $text\n\n";
    
    // echo $public_key;
    // echo $private_key;
    
//     $public_key = '-----BEGIN PUBLIC KEY-----
// MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAkzJyv2o0g0iOuEcabGFy
// V1uaeGEy7Kh+4iUArYMpzj4M0OP2DEYgPZFLxumHUZQzS4mvVdW7W4kY8OMOVFxF
// 0EN2jKub8hpQVlHhAAAFqIB61Pz7UMR5MX+gTRzelh7B3L2nmjxDoVhxwAjhZ3Bt
// wLl3ppOyrm2/k7rHrLK1sChUT+wwBRXOTtZz8AqzJ3WdOnXa6qIWxeCbSSghnn3N
// GQR5OifmbpwC+CAfGt5nJS4ke9XEt6RnSkRNdIhg9hy6kGwTiXuLMZuZuv9S0v3u
// EpzUCuLdELoDuXLW2lKgMLYxnpX1A9HWKLSTYu/mKPx9ZzGh5PR7AKH9aAkCFXU+
// /QIDAQAB
// -----END PUBLIC KEY-----';

//     $private_key = '-----BEGIN PRIVATE KEY-----
// MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCTMnK/ajSDSI64
// RxpsYXJXW5p4YTLsqH7iJQCtgynOPgzQ4/YMRiA9kUvG6YdRlDNLia9V1btbiRjw
// 4w5UXEXQQ3aMq5vyGlBWUeEAAAWogHrU/PtQxHkxf6BNHN6WHsHcvaeaPEOhWHHA
// COFncG3AuXemk7Kubb+TusessrWwKFRP7DAFFc5O1nPwCrMndZ06ddrqohbF4JtJ
// KCGefc0ZBHk6J+ZunAL4IB8a3mclLiR71cS3pGdKRE10iGD2HLqQbBOJe4sxm5m6
// /1LS/e4SnNQK4t0QugO5ctbaUqAwtjGelfUD0dYotJNi7+Yo/H1nMaHk9HsAof1o
// CQIVdT79AgMBAAECggEAbivoLtSzEUARcmPlpxEYn8H0T/2QPAmxTlobs8LkW3Wd
// 6gt1caJbJznE2dCYc7rU2cjn7vrWDKEEheesJgAaUNLtvEQFqKOBVdpa6cEaexAO
// 37Op9r3XZ/D6bj0ZbIsA1tMsywgoJm8oVG9RJjbELueiYo9RwbRrG4tFQEFSM9IZ
// Ejaa/X57otdr+0Bff3+X6E2znmyqE5MDRdqwRy6mfrphu/2tTLlG0aNZEuhg2lfe
// ffCvpIyRaG3R2JMBHW1AqhXNqumUGufI7TV29TCD6OlpqSmXa/u8woyNoJY7h025
// uRSp6ZOWb25gIae6FvF0w1rDvzQrGESBgAzIKQDYAQKBgQDCwUQyJihseKWFs8jU
// DXlL/BZ6GLc67xgHYlpy6wcawEI4iuz5b1HJJBbNvNEYh2CpzyAUtx67au4DUhQu
// Z9uGH8u6TRvxROMKuRRq7WBeJNj3c9jhMwhA3W1qibT9akkIAq+YUXPerhN4AgCD
// NLF28UuZUgx9shY9aljaA/gJgQKBgQDBfImnIZ4nEHs2flPPcgC0UhzY8E+k/zwx
// p8+XhOU0VUnxaBwAgOpNz+RFH1VfIscbk27zt3oDMNHCExBhpjUwuj4RCyb4Z/ON
// 9WEv8kTa7ZdXTi+0EN2Iqqn3HLggayaeKjKgbVKsP2va5KQsHtcf0galbKQsQRVF
// QluLuFgbfQKBgQCAPuw9acsswrWcuasBmG3Lj5DtjeD6uf9EvYt6KTJgd0IkIbey
// +Y8NuOobSL8YO+13ZKFngr6GA///x8jqVhHE3KM3ZxeDZS1tHjtHvlC7LeCB8pNa
// mFRTAnzOryezyI2W7M3cq6Z1eIPxfr//pm9GN9bke5cmHmNuxd0Ek6B+AQKBgHIA
// RMK6pgpyRYaoDA2QKCYWs3SGswaOdBL1wvSNktaw4e5g3w7U5jiOovqvKYfyX8o5
// pgfnNPaoTw7AWMiQO4rIUUWNgpqd9PzRdT/gyP0NPDxujuDThxO9KoO04jAHsitC
// xa2MfEeM3qmMScbNLQdMoinZxylj93plTLcYGKGpAoGBALXM1qgR0P+vlYe3cTEi
// +WRRM5iiuIOj9n1SfI6ESso7iamFDgtc+AX7uqookwmm3bojkn8Jph2325NFkrIT
// UJ216gFkczSKelMSCNp9p/bgRo1S4Duij+U4GMJWYJO4mxS1dR4ORTQJTlSM4xoL
// cdTa9jmSyGqZDgoG3TU6vfQ6
// -----END PRIVATE KEY-----';
    
    // Encrypt using the public key
    openssl_public_encrypt($text, $encrypted, $public_key);
    
    $encrypted_hex = base64_encode($encrypted);
    echo PHP_EOL . "This is the encrypted text: $encrypted_hex\n\n";
    
    // Decrypt the data using the private key
    openssl_private_decrypt($encrypted, $decrypted, $private_key);
    
    echo "This is the decrypted text: $decrypted\n\n";
    
    // echo $private_key;
    
?>