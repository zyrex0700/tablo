<?php

declare(strict_types=1);

class SmsService
{
    private static string $baseUrl = 'https://edge.ippanel.com/v1';

    // 🔑 توکن IPPanel
    private static string $authToken = 'OWY5NzM0NGQtMDIwYy00ZDNmLWJmODYtOGEzMDRhZDhkNDZmMjg5YmUxY2ZhZTFmNzNkMjNlZTM4MDczYzlhMjk5MjQ=';

    // 📞 خط ارسال‌کننده
    private static string $fromNumber = '+983000505';

    // 🧩 کد الگو
    private static string $patternCode = 'izuomd5dooahad5';

    public static function setConfig(?string $authToken = null, ?string $fromNumber = null, ?string $patternCode = null): void
    {
        $envToken = getenv('IPPANEL_AUTH_TOKEN');
        $envFrom = getenv('IPPANEL_FROM_NUMBER');
        $envPattern = getenv('IPPANEL_PATTERN_CODE');

        self::$authToken = $authToken ?? ($envToken !== false ? $envToken : self::$authToken);
        self::$fromNumber = $fromNumber ?? ($envFrom !== false ? $envFrom : self::$fromNumber);
        self::$patternCode = $patternCode ?? ($envPattern !== false ? $envPattern : self::$patternCode);
    }

    private static function normalizePhone(string $phone): string
    {
        $phone = preg_replace('/\D+/', '', $phone ?? '');

        if (strpos($phone, '00') === 0) {
            $phone = substr($phone, 2);
        }

        if (strpos($phone, '0') === 0) {
            $phone = substr($phone, 1);
        }

        if (strpos($phone, '98') !== 0) {
            $phone = '98' . $phone;
        }

        return '+' . $phone;
    }

    public static function sendOtp(string $phone, string $code): array
    {
        self::setConfig();

        $to = self::normalizePhone($phone);

        $payload = [
            'sending_type' => 'pattern',
            'from_number' => self::$fromNumber,
            'code' => self::$patternCode,
            'recipients' => [$to],
            'params' => [
                'code' => $code,
            ],
        ];

        $url = self::$baseUrl . '/api/send';

        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_POST => true,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => [
                'Content-Type: application/json',
                'Authorization: ' . self::$authToken,
            ],
            CURLOPT_POSTFIELDS => json_encode($payload, JSON_UNESCAPED_UNICODE),
            CURLOPT_SSL_VERIFYPEER => true,
            CURLOPT_TIMEOUT => 20,
        ]);

        $response = curl_exec($ch);
        $err = curl_error($ch);
        curl_close($ch);

        if ($err) {
            error_log("IPPanel pattern SMS error: $err");
            return [
                'success' => false,
                'message' => 'خطا در اتصال به پنل پیامک.',
            ];
        }

        $data = json_decode((string) $response, true);

        if (!is_array($data) || !isset($data['meta']['status'])) {
            error_log('IPPanel pattern SMS invalid response: ' . $response);
            return [
                'success' => false,
                'message' => 'پاسخ پنل پیامک نامعتبر است.',
            ];
        }

        if ($data['meta']['status'] !== true) {
            $message = $data['meta']['message'] ?? 'ارسال پیامک ناموفق بود.';
            error_log('IPPanel pattern SMS failed: ' . $message);

            return [
                'success' => false,
                'message' => (string) $message,
            ];
        }

        return [
            'success' => true,
            'message' => 'کد تایید ارسال شد.',
        ];
    }
}
