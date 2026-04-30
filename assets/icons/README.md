# App Icons

게임 특성(숫자 찾기 1→50, 카드 탭 상호작용) 을 반영한 런처 아이콘 에셋.

## 파일

| 파일 | 용도 | 변환 대상 |
|---|---|---|
| `foreground.svg` | Android adaptive icon 전경 | `foreground.png` (1024×1024) |
| `legacy.svg` | iOS + Android 7 이하 legacy 단일 아이콘 | `legacy.png` (1024×1024) |
| `monochrome.svg` | Android 13+ 테마드 아이콘 (단색) | `monochrome.png` (1024×1024) |

## 디자인 컨셉

- **카드**: 5×5 보드 타일 모티브 → "탭해서 시작" 은유
- **골드 "1"**: 시작 숫자 + 타이틀 "1TO50" 의 첫 글자와 시각 일관성
- **딥 네이비 배경**: 앱 테마 `AppColors.cardBorder` 와 통일
- **안전영역 준수**: 중심 반지름 313px 내에 모든 시각 요소 배치

## SVG → PNG 변환 (30초)

로컬에 ImageMagick/Inkscape/rsvg 가 없어 온라인 툴 사용 권장.

### 추천 도구

- **cloudconvert.com/svg-to-png** — 드래그·드롭, 1024×1024 출력 지정
- **svgtopng.com** — 간단 UI
- Figma 에 SVG 붙여넣고 PNG export 도 가능

### 변환 순서

1. `foreground.svg` → `foreground.png` (1024×1024, 투명 배경 유지)
2. `legacy.svg` → `legacy.png` (1024×1024)
3. `monochrome.svg` → `monochrome.png` (1024×1024, 투명 배경 유지)

세 PNG 파일을 이 디렉토리에 같은 이름으로 저장.

## 적용 (PNG 준비 후)

```yaml
# pubspec.yaml 에 추가
dev_dependencies:
  flutter_launcher_icons: ^0.14.0

flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/icons/legacy.png"
  adaptive_icon_background: "#022F78"
  adaptive_icon_foreground: "assets/icons/foreground.png"
  adaptive_icon_monochrome: "assets/icons/monochrome.png"
  min_sdk_android: 21
```

```bash
flutter pub get
dart run flutter_launcher_icons
```

자동 생성되는 파일:
- `android/app/src/main/res/mipmap-*/ic_launcher.png` (모든 dpi)
- `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` (adaptive)
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/*` (iOS 아이콘셋)

## 디자인 수정 시

SVG 만 편집 후 PNG 재변환 → `dart run flutter_launcher_icons` 재실행.
