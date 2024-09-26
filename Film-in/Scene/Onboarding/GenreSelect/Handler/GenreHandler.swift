//
//  GenreHandler.swift
//  Film-in
//
//  Created by Minjae Kim on 9/24/24.
//

import UIKit

// MARK: - Tag 관련 Method 보관
enum GenreHandler {
    static var windowWidth: CGFloat {
        getScreenWidthWithoutPadding(padding: 20)
    }
    
    // horizontal에 들어가있는 (padding * 2)를 화면 width에서 뺄셈해준 width 값을 얻기 위한 메서드
    static func getScreenWidthWithoutPadding(padding: CGFloat) -> CGFloat {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        let windowWidth = (window?.screen.bounds.width ?? 0) - (padding * 2)
        return windowWidth
    }
    
    // string에 대한 fontSize를 get하는 메서드
    private static func getFontSize(genre: String, fontSize: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let attributes = [NSAttributedString.Key.font: font]
        let size = (genre as NSString).size(withAttributes: attributes)
        return size.width
    }
    
    // genre로 가져온 문자열 배열을 화면의 width에 맞게 계산하여 2차원 배열로 매핑해주기 위한 메서드
    static func getRows(genres: Set<MovieGenre>, spacing: CGFloat, fontSize: CGFloat, windowWidth: CGFloat) -> [[MovieGenre]] {
        var rows: [[MovieGenre]] = [] // genre 값을 담아주기 위한 2차원 배열 프로퍼티
        var currentRow: [MovieGenre] = [] // 화면상의 width에 맞게 genre 배열을 잘라 2차원 배열에 담아줄 프로퍼티
        var totalWidth: CGFloat = 0 // 화면상의 width와 비교하여 계산하기 위한 1차원 배열의 총 width를 계산해서 담아줄 저장 프로퍼티
        
        genres.sorted(by: { $0.name < $1.name }).forEach { genre in
            let fontSize = getFontSize(genre: genre.name, fontSize: fontSize) + spacing // size = genre 문자열 + spacing
            totalWidth += fontSize
            
            // 1. 총합 width가 화면 상의 width 보다 클 경우
            if totalWidth > windowWidth {
                // 2. 잘라주며 담아준 1차원 배열을 2차원 배열에 append
                rows.append(currentRow)
                // 3. 1차원 배열의 데이터를 다 지워주면서
                currentRow.removeAll()
                // 4. 최근 genre값을 1차원 배열에 append
                currentRow.append(genre)
                // 5. 총합 width에 계산된 최근 genre에 대한 width값을 담아준다.
                totalWidth = fontSize
            } else {
                // 1. 총합 width가 화면 상의 width 보다 작을 경우
                // 2. 1차원 배열에 genre 값을 append
                currentRow.append(genre)
            }
        }
        
        // 1. genre값이 담긴 1차원 배열에 데이터가 남아있는 경우
        if !currentRow.isEmpty {
            // 2. 2차원 배열에 1차원 배열을 append
            rows.append(currentRow)
            // 3. genre값이 담긴 1차원 배열의 데이터를 다 지워준다
            currentRow.removeAll()
        }
        
        return rows
    }
}
