# HBJJGAMES Web Portal

HBJJ Games 의 공용 웹 포털 (Flutter Web). 자사 게임 라인업 / 회사 소개 / 법적 문서(privacy / tos) 호스팅 용도. **public repo** 로 배포 예정.

## 수정 전 반드시 읽을 파일

- **디자인 시스템 (HBJJ Games 패밀리 토큰)** → `~/Documents/HBJJGAMES/design.md` (SSOT — 컬러/타이포/라운드/스페이싱/모션/공용 컴포넌트). 신규 토큰 도입 시 이 파일 먼저 갱신.
- 같은 패밀리 내 자매 프로젝트 → `~/Documents/HBJJGAMES/1to50/` (게임 클라이언트, private repo)

## 디자인 원칙

이 웹은 1to50 등 패밀리 게임과 시각적으로 같은 계열로 느껴져야 함. design.md 의 토큰을 그대로 따르고, 게임 자체의 보드/카드 같은 *게임 고유 컴포넌트* 는 들여오지 않음 — 웹은 *공용 컴포넌트* (button-primary/ghost, dialog, list-row, tab) 만 사용.

특히:
- 배경은 `surface-base` (#000000) 로 고정. light theme 만들지 말 것.
- 카드형 면에는 `border-strong` (#FFFFFF, 2px) 프레임 필수.
- 본문 텍스트에 yellow/gold 사용 금지 (성취/타이틀 전용).

## Tech Stack

- Flutter Web
- 배포 보류 중 — 자세한 진행상황은 memory `project_hbjjgames_web.md` 참조.

## Key Commands

```bash
flutter run -d chrome --web-port 8080   # 로컬 dev
flutter build web --release             # 배포 빌드
flutter analyze
flutter test
```
