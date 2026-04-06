# Simula Take-Home Requirement Checklist

Source: `requeriments.txt`

## Task 1 Scope

- [x] Native Swift framework/module created (`SimulaMiniGameSDK` Swift Package).
- [x] Includes menu view component (`SimulaMiniGameMenuSDKView`, equivalent to `MiniGameMenuView` requirement intent).
- [x] Includes provider/data layer (`MiniGameProvider` + business layer).

## Layout Requirements

- [x] iPad: fixed 4-column `LazyVGrid` on `regular` size class.
- [x] iPhone: horizontal swipe carousel using `TabView` with `.page`.
- [x] One-card peek behavior on compact width via explicit card width + side padding.
- [x] Responsive switching based on `horizontalSizeClass`.

## UI/Behavior Requirements

- [x] Loading state implemented for menu and game init.
- [x] Empty state implemented.
- [x] Error state implemented with retry action.
- [x] Card UI includes image fallback chain (`gif_cover` -> icon -> emoji fallback).
- [x] Post-game fallback ad flow implemented.
- [x] Fallback ad close lock (5-second countdown) implemented.

## Provider/Data Contract

- [x] Session creation endpoint integrated (`/session/create`).
- [x] Catalog fetch endpoint integrated (`/minigames/catalogv2`) with shape compatibility.
- [x] Minigame init endpoint integrated (`/minigames/init`).
- [x] Fallback ad endpoint integrated (`/minigames/fallback_ad/{aid}`).
- [x] Menu click tracking endpoint integrated (`/minigames/menu/track/click`) as best effort.
- [x] Uses `async/await` networking.

## Project Technical Requirements

- [x] Pure SwiftUI core layout.
- [x] iOS deployment target is 16+ (SDK package and app project).
- [x] Sample integration view exists in `simula/simula/ContentView.swift`.
- [x] Main app consumes SDK with API key only (host-friendly integration).

## Production/Integration Ergonomics

- [x] SDK is reusable as standalone package (`SimulaMiniGameSDK`).
- [x] Host callbacks added: `onGameOpen`, `onGameClose`, `onError`.
- [x] Unit tests included for decoder variants and ViewModel flow states.

## Manual Visual QA Still Required

- [ ] Pixel-level visual parity sign-off against `coolaigames.com/maya` screenshots on iPhone+iPad simulators.
- [ ] Final spacing/typography tuning pass using side-by-side captures from the reference deployment.

These final two items require device/simulator visual comparison and cannot be conclusively auto-verified from code alone.
