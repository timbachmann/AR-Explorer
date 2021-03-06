# Swift5 API client for OpenAPIClient

Used to get and store Images of AR-Explorer

## Overview
This API client was generated by the [OpenAPI Generator](https://openapi-generator.tech) project.  By using the [openapi-spec](https://github.com/OAI/OpenAPI-Specification) from a remote server, you can easily generate an API client.

- API version: 1.0.0
- Package version: 
- Build package: org.openapitools.codegen.languages.Swift5ClientCodegen

## Installation

### Carthage

Run `carthage update`

### CocoaPods

Run `pod install`

## Documentation for API Endpoints

All URIs are relative to *http://localhost*

Class | Method | HTTP request | Description
------------ | ------------- | ------------- | -------------
*ImageAPI* | [**createImage**](docs/ImageAPI.md#createimage) | **POST** /images | Create new image
*ImageAPI* | [**deleteImageById**](docs/ImageAPI.md#deleteimagebyid) | **DELETE** /images/{userID}/{imageId} | Delete image by id
*ImageAPI* | [**getAllImagesWithFilter**](docs/ImageAPI.md#getallimageswithfilter) | **GET** /images | Get all images with filter
*ImageAPI* | [**getImageById**](docs/ImageAPI.md#getimagebyid) | **GET** /images/{userID}/{imageId} | Get image by id
*ImageAPI* | [**updateImageById**](docs/ImageAPI.md#updateimagebyid) | **PUT** /images/{userID}/{imageId} | Update image by id


## Documentation For Models

 - [ApiImage](docs/ApiImage.md)
 - [ImageListResponse](docs/ImageListResponse.md)
 - [ModelErrorResponse](docs/ModelErrorResponse.md)
 - [NewImageRequest](docs/NewImageRequest.md)


## Documentation For Authorization

 All endpoints do not require authorization.


## Author



