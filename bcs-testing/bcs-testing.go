package main

import (
    "log"

    "github.com/minio/minio-go"
)

func main() {
    // Requests are always secure (HTTPS) by default. Set secure=false to enable insecure (HTTP) access.
    // This boolean value is the last argument for New().

    // New returns an Amazon S3 compatible client object. API copatibality (v2 or v4) is automatically
    // determined based on the Endpoint value.
    secure := false // Defaults to HTTPS requests.
    s3Client, err := minio.New("s3.amazonaws.com", "<your access key>", "<your secret key>", secure)
    if err != nil {
        log.Fatalln(err)
    }
    buckets, err := s3Client.ListBuckets()
    if err != nil {
        log.Fatalln(err)
    }
    for _, bucket := range buckets {
        log.Println(bucket)
    }
}
