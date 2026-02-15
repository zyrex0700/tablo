# OTP auth backend suggestion (IPPanel Edge)

این پوشه یک نمونه‌ی آماده برای اتصال ورود OTP فرانت پروژه به IPPanel است.

## فایل‌ها
- `SmsService.php`: سرویس ارسال پیامک Pattern با Edge API.
- `send_otp.php`: تولید OTP و ارسال پیامک.
- `verify_otp.php`: تایید OTP.

## تنظیمات لازم
مقادیر زیر را روی سرور تنظیم کنید (ENV):
- `IPPANEL_AUTH_TOKEN`
- `IPPANEL_FROM_NUMBER`
- `IPPANEL_PATTERN_CODE`

## مسیرهای API
این دو فایل را روی سرور در مسیر زیر قرار دهید تا با فرانت فعلی همخوان باشد:
- `https://tablo.ir/my_api/auth/send_otp.php`
- `https://tablo.ir/my_api/auth/verify_otp.php`

## نکته امنیتی
فایل `otp_store.json` صرفاً نمونه‌ی ساده است. برای production بهتر است OTP در Redis/Database با rate-limit و attempt-limit ذخیره شود.
