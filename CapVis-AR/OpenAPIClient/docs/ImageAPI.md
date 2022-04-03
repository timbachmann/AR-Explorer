# ImageAPI

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createImage**](ImageAPI.md#createimage) | **POST** /images | Create new image
[**deleteImageById**](ImageAPI.md#deleteimagebyid) | **DELETE** /images/{imageId} | Delete image by id
[**getAllImagesWithFilter**](ImageAPI.md#getallimageswithfilter) | **GET** /images | Get all images with filter
[**getImageById**](ImageAPI.md#getimagebyid) | **GET** /images/{imageId} | Get image by id


# **createImage**
```swift
    open class func createImage(newImageRequest: NewImageRequest? = nil, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Create new image

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let newImageRequest = NewImageRequest(id: "id_example", data: [123], lat: 123, lng: 123, date: "date_example", source: "source_example", bearing: 123) // NewImageRequest |  (optional)

// Create new image
ImageAPI.createImage(newImageRequest: newImageRequest) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **newImageRequest** | [**NewImageRequest**](NewImageRequest.md) |  | [optional] 

### Return type

Void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteImageById**
```swift
    open class func deleteImageById(imageId: String, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Delete image by id

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let imageId = "imageId_example" // String | id to search for

// Delete image by id
ImageAPI.deleteImageById(imageId: imageId) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **imageId** | **String** | id to search for | 

### Return type

Void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAllImagesWithFilter**
```swift
    open class func getAllImagesWithFilter(startDate: String, endDate: String, lat: String, lng: String, radius: String, completion: @escaping (_ data: ImageListResponse?, _ error: Error?) -> Void)
```

Get all images with filter

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let startDate = "startDate_example" // String | start date for temporal filter
let endDate = "endDate_example" // String | end date for temporal filter
let lat = "lat_example" // String | latitude for spatial filter
let lng = "lng_example" // String | longitude for spatial filter
let radius = "radius_example" // String | radius for spatial filter

// Get all images with filter
ImageAPI.getAllImagesWithFilter(startDate: startDate, endDate: endDate, lat: lat, lng: lng, radius: radius) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **startDate** | **String** | start date for temporal filter | 
 **endDate** | **String** | end date for temporal filter | 
 **lat** | **String** | latitude for spatial filter | 
 **lng** | **String** | longitude for spatial filter | 
 **radius** | **String** | radius for spatial filter | 

### Return type

[**ImageListResponse**](ImageListResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getImageById**
```swift
    open class func getImageById(imageId: String, completion: @escaping (_ data: ApiImage?, _ error: Error?) -> Void)
```

Get image by id

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let imageId = "imageId_example" // String | id to search for

// Get image by id
ImageAPI.getImageById(imageId: imageId) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **imageId** | **String** | id to search for | 

### Return type

[**ApiImage**](ApiImage.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

