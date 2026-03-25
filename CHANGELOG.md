## 2.0.0

### Bug Fixes
* Fixed infinite recursion in `beep()` method (stack overflow for n > 9)
* Fixed broken `_toRasterFormat()` image rasterization logic
* Fixed socket leak and error handling in network printer
* Made `PosColumn` fields immutable to prevent bypassing validation
* Added error handling for missing/malformed `capabilities.json`

### New Features
* **Line spacing control** — `setLineSpacing(n)` and `resetLineSpacing()` (ESC 2, ESC 3)
* **PDF417 2D barcode** — full implementation with columns, rows, module size, error correction, truncated mode
* **CODE93 barcode** — `Barcode.code93()` (GS k m=72)
* **GS1-128 barcode** — `Barcode.gs1_128()` (GS k m=74)
* **QR Code model selection** — Model 1, Model 2, Micro QR via `QRModel` enum
* **QR Code sizes 9-16** — extended from 1-8 to full ESC/POS spec range 1-16

### Breaking Changes
* Minimum SDK updated to `>=3.2.3 <4.0.0`
* Minimum Flutter updated to `>=3.16.5`
* `image` dependency updated to `^4.8.0`
* `PosColumn` fields are now `final` (previously mutable)

### Tests
* Added comprehensive test suite (126 tests)

## 1.0.1

* Minor bug fixes

## 1.0.0

* image package update

## 0.1.8

* Minor bug fixes

## 0.1.7

* Minor bug fixes

## 0.1.6

* Added 72mm Paper Size 
* Added Single density image print

## 0.1.4

* Fix change row issue
* Fix CJK(Chinese, Japanese and Korean) String overlap when using Generator.row() method

## 0.1.3

* Added clearStyle function

## 0.1.0

* Fix barcode printing in some printers
* Added more printer code tables
* Added non-latin characters support

## 0.0.5

* Fix compile time warnings

## 0.0.4

* example added

## 0.0.2

* Initial release.

## 0.0.1

* Initial release.