//
//  ToasterAPIService.swift
//  TOASTER-iOS
//
//  Created by 김다예 on 1/15/24.
//

import Foundation

import Moya

protocol ToasterAPIServiceProtocol {
    func postSaveLink(requestBody: PostSaveLinkRequestDTO,
                      completion: @escaping (NetworkResult<NoneDataResponseDTO>) -> Void)
    func patchOpenLink(requestBody: PatchOpenLinkRequestDTO,
                       completion: @escaping (NetworkResult<PatchOpenLinkResponseDTO>) -> Void)
    func deleteLink(toastId: Int,
                    completion: @escaping (NetworkResult<NoneDataResponseDTO>) -> Void)
    func getWeeksLink(completion: @escaping (NetworkResult<GetWeeksLinkResponseDTO>) -> Void)
    func patchEditLinkTitle(requestBody: PatchEditLinkTitleRequestDTO,
                            completion: @escaping (NetworkResult<PatchEditLinkTitleResponseDTO>) -> Void)
    func getRecentLink(completion: @escaping (NetworkResult<GetRecentLinkResponseDTO>) -> Void)
    func patchChangeCategory(requestBody: PatchChangeCategoryRequestDTO,
                             completion: @escaping (NetworkResult<PatchChangeCategoryResponseDTO>) -> Void)
}

final class ToasterAPIService: BaseAPIService, ToasterAPIServiceProtocol {
    
    private let provider = MoyaProvider<ToasterTargetType>.init(session: Session(interceptor: APIInterceptor.shared), plugins: [MoyaPlugin()])

    func postSaveLink(requestBody: PostSaveLinkRequestDTO, 
                      completion: @escaping (NetworkResult<NoneDataResponseDTO>) -> Void) {
        provider.request(.postSaveLink(requestBody: requestBody)) { result in
            switch result {
            case .success(let response):
                let networkResult: NetworkResult<NoneDataResponseDTO> = self.fetchNetworkResult(statusCode: response.statusCode, data: response.data)
                print(networkResult.stateDescription)
                completion(networkResult)
            case .failure(let error):
                if let response = error.response {
                    let networkResult: NetworkResult<NoneDataResponseDTO> = self.fetchNetworkResult(statusCode: response.statusCode, data: response.data)
                    completion(networkResult)
                }
            }
        }
    }
    
    func patchOpenLink(requestBody: PatchOpenLinkRequestDTO, 
                       completion: @escaping (NetworkResult<PatchOpenLinkResponseDTO>) -> Void) {
        provider.request(.patchOpenLink(requestBody: requestBody)) { result in
            switch result {
            case .success(let response):
                let networkResult: NetworkResult<PatchOpenLinkResponseDTO> = self.fetchNetworkResult(statusCode: response.statusCode, data: response.data)
                print(networkResult.stateDescription)
                completion(networkResult)
            case .failure(let error):
                if let response = error.response {
                    let networkResult: NetworkResult<PatchOpenLinkResponseDTO> = self.fetchNetworkResult(statusCode: response.statusCode, data: response.data)
                    completion(networkResult)
                }
            }
        }
    }
    
    func deleteLink(toastId: Int,
                    completion: @escaping (NetworkResult<NoneDataResponseDTO>) -> Void) {
        provider.request(.deleteLink(toastId: toastId)) { result in
            switch result {
            case .success(let response):
                let networkResult: NetworkResult<NoneDataResponseDTO> = self.fetchNetworkResult(statusCode: response.statusCode, data: response.data)
                print(networkResult.stateDescription)
                completion(networkResult)
            case .failure(let error):
                if let response = error.response {
                    let networkResult: NetworkResult<NoneDataResponseDTO> = self.fetchNetworkResult(statusCode: response.statusCode, data: response.data)
                    completion(networkResult)
                }
            }
        }
    }
    
    func getWeeksLink(completion: @escaping (NetworkResult<GetWeeksLinkResponseDTO>) -> Void) {
        provider.request(.getWeeksLink) { result in
            switch result {
            case .success(let response):
                let networkResult: NetworkResult<GetWeeksLinkResponseDTO> = self.fetchNetworkResult(statusCode: response.statusCode, data: response.data)
                print(networkResult.stateDescription)
                completion(networkResult)
            case .failure(let error):
                if let response = error.response {
                    let networkResult: NetworkResult<GetWeeksLinkResponseDTO> = self.fetchNetworkResult(statusCode: response.statusCode, data: response.data)
                    completion(networkResult)
                }
            }
        }
    }
    
    func patchEditLinkTitle(requestBody: PatchEditLinkTitleRequestDTO, 
                            completion: @escaping (NetworkResult<PatchEditLinkTitleResponseDTO>) -> Void) {
        provider.request(.patchEditLinkTitle(requestBody: requestBody)) { result in
            switch result {
            case .success(let response):
                let networkResult: NetworkResult<PatchEditLinkTitleResponseDTO> = self.fetchNetworkResult(statusCode: response.statusCode, data: response.data)
                print(networkResult.stateDescription)
                completion(networkResult)
            case .failure(let error):
                if let response = error.response {
                    let networkResult: NetworkResult<PatchEditLinkTitleResponseDTO> = self.fetchNetworkResult(statusCode: response.statusCode, data: response.data)
                    completion(networkResult)
                }
            }
        }
    }
    
    func getRecentLink(completion: @escaping (NetworkResult<GetRecentLinkResponseDTO>) -> Void) {
        provider.request(.getRecentLink) { result in
            switch result {
            case .success(let response):
                let networkResult: NetworkResult<GetRecentLinkResponseDTO> = self.fetchNetworkResult(statusCode: response.statusCode, data: response.data)
                print(networkResult.stateDescription)
                completion(networkResult)
            case .failure(let error):
                if let response = error.response {
                    let networkResult: NetworkResult<GetRecentLinkResponseDTO> = self.fetchNetworkResult(statusCode: response.statusCode, data: response.data)
                    completion(networkResult)
                }
            }
        }
    }
    
    func patchChangeCategory(requestBody: PatchChangeCategoryRequestDTO,
                             completion: @escaping (NetworkResult<PatchChangeCategoryResponseDTO>) -> Void) {
        provider.request(.patchChangeCategory(requestBody: requestBody)) { result in
            switch result {
            case .success(let response):
                let networkResult: NetworkResult<PatchChangeCategoryResponseDTO> = self.fetchNetworkResult(statusCode: response.statusCode, data: response.data)
                print(networkResult.stateDescription)
                completion(networkResult)
            case .failure(let error):
                if let response = error.response {
                    let networkResult: NetworkResult<PatchChangeCategoryResponseDTO> = self.fetchNetworkResult(statusCode: response.statusCode, data: response.data)
                    completion(networkResult)
                }
            }
        }
    }
}
