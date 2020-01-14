//
//  LeftHalfCalculation.swift
//  Rectangle, Ported from Spectacle
//
//  Created by Ryan Hanson on 6/13/19.
//  Copyright © 2019 Ryan Hanson. All rights reserved.
//

import Cocoa

class LeftRightHalfCalculation: WindowCalculation, RepeatedExecutionsCalculation {
    
    func calculate(_ windowRect: CGRect, lastAction: RectangleAction?, usableScreens: UsableScreens, action: WindowAction) -> WindowCalculationResult? {
        
        switch Defaults.subsequentExecutionMode.value {
            
        case .acrossMonitor:
            if action == .leftHalf {
                return calculateLeftAcrossDisplays(windowRect, lastAction: lastAction, screen: usableScreens.currentScreen, usableScreens: usableScreens)
            } else if action == .rightHalf {
                return calculateRightAcrossDisplays(windowRect, lastAction: lastAction, screen: usableScreens.currentScreen, usableScreens: usableScreens)
            }
            return nil
        case .resize:
            let screen = usableScreens.currentScreen
            let rect: CGRect = calculateRepeatedRect(windowRect, lastAction: lastAction, visibleFrameOfScreen: screen.visibleFrame, action: action)
            return WindowCalculationResult(rect: rect, screen: screen, resultingAction: action)
        case .none:
            let screen = usableScreens.currentScreen
            let oneHalfRect = calculateFirstRect(windowRect, lastAction: lastAction, visibleFrameOfScreen: screen.visibleFrame, action: action)
            return WindowCalculationResult(rect: oneHalfRect, screen: screen, resultingAction: action)
        }
        
    }

    func calculateFirstRect(_ windowRect: CGRect, lastAction: RectangleAction?, visibleFrameOfScreen: CGRect, action: WindowAction) -> CGRect {

        var oneHalfRect = visibleFrameOfScreen
        oneHalfRect.size.width = floor(oneHalfRect.width / 2.0)
        if action == .rightHalf {
            oneHalfRect.origin.x += oneHalfRect.size.width
        }
        return applyUselessGaps(oneHalfRect, sharedEdges: action == .rightHalf ? .left : .right)
    }

    func calculateSecondRect(_ windowRect: CGRect, lastAction: RectangleAction?, visibleFrameOfScreen: CGRect, action: WindowAction) -> CGRect {
        
        var twoThirdsRect = visibleFrameOfScreen
        twoThirdsRect.size.width = floor(visibleFrameOfScreen.width * 2 / 3.0)
        if action == .rightHalf {
            twoThirdsRect.origin.x = visibleFrameOfScreen.minX + visibleFrameOfScreen.width - twoThirdsRect.width
        }
        return applyUselessGaps(twoThirdsRect, sharedEdges: action == .rightHalf ? .left : .right)
    }

    func calculateThirdRect(_ windowRect: CGRect, lastAction: RectangleAction?, visibleFrameOfScreen: CGRect, action: WindowAction) -> CGRect {

        var oneThirdRect = visibleFrameOfScreen
        oneThirdRect.size.width = floor(visibleFrameOfScreen.width / 3.0)
        if action == .rightHalf {
            oneThirdRect.origin.x = visibleFrameOfScreen.origin.x + visibleFrameOfScreen.width - oneThirdRect.width
        }
        return applyUselessGaps(oneThirdRect, sharedEdges: action == .rightHalf ? .left : .right)
    }

    func calculateLeftAcrossDisplays(_ windowRect: CGRect, lastAction: RectangleAction?, screen: NSScreen, usableScreens: UsableScreens) -> WindowCalculationResult? {
                
        if let lastAction = lastAction, lastAction.action == .leftHalf {
            let normalizedLastRect = AccessibilityElement.normalizeCoordinatesOf(lastAction.rect, frameOfScreen: usableScreens.frameOfCurrentScreen)
            if normalizedLastRect == windowRect {
                if let prevScreen = usableScreens.adjacentScreens?.prev {
                    return calculateRightAcrossDisplays(windowRect, lastAction: lastAction, screen: prevScreen, usableScreens: usableScreens)
                }
            }
        }
        
        let oneHalfRect = calculateFirstRect(windowRect, lastAction: lastAction, visibleFrameOfScreen: screen.visibleFrame, action: .leftHalf)
        return WindowCalculationResult(rect: oneHalfRect, screen: screen, resultingAction: .leftHalf)
    }
    
    
    func calculateRightAcrossDisplays(_ windowRect: CGRect, lastAction: RectangleAction?, screen: NSScreen, usableScreens: UsableScreens) -> WindowCalculationResult? {
        
        if let lastAction = lastAction, lastAction.action == .rightHalf {
            let normalizedLastRect = AccessibilityElement.normalizeCoordinatesOf(lastAction.rect, frameOfScreen: usableScreens.frameOfCurrentScreen)
            if normalizedLastRect == windowRect {
                if let nextScreen = usableScreens.adjacentScreens?.next {
                    return calculateLeftAcrossDisplays(windowRect, lastAction: lastAction, screen: nextScreen, usableScreens: usableScreens)
                }
            }
        }
        
        let oneHalfRect = calculateFirstRect(windowRect, lastAction: lastAction, visibleFrameOfScreen: screen.visibleFrame, action: .rightHalf)
        return WindowCalculationResult(rect: oneHalfRect, screen: screen, resultingAction: .rightHalf)
    }

    // Used to draw box for snapping
    func calculateRect(_ windowRect: CGRect, lastAction: RectangleAction?, visibleFrameOfScreen: CGRect, action: WindowAction) -> CGRect? {
        switch action {
        case .leftHalf:
            var oneHalfRect = visibleFrameOfScreen
            oneHalfRect.size.width = floor(oneHalfRect.width / 2.0)
            return oneHalfRect
        case .rightHalf:
            var oneHalfRect = visibleFrameOfScreen
            oneHalfRect.size.width = floor(oneHalfRect.width / 2.0)
            oneHalfRect.origin.x += oneHalfRect.size.width
            return oneHalfRect
        default:
            return nil
        }
    }
}
