# Tablo Rebuild (Flutter Web + GetX)

این ریپو نقطه شروع بازسازی سایت **tablo.ir** است.

## وضعیت فعلی
- اسکلت اولیه Flutter Web آماده شده است.
- معماری پایه با GetX (routes/bindings/controllers) اضافه شده است.
- یک صفحه Home اولیه برای شروع بازسازی پیاده‌سازی شده است.

## اجرای پروژه
```bash
flutter pub get
flutter run -d chrome
```

## نقشه راه کوتاه
1. پیاده‌سازی layout اصلی صفحه خانه
2. ساخت کامپوننت‌های قابل استفاده مجدد (Navbar, Hero, Pricing, Footer)
3. اتصال به API و مدیریت state با GetX
4. SEO پایه برای وب + بهینه‌سازی performance
