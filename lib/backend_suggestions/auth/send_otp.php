<?php

declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/SmsService.php';

function jsonResponse(array $payload, int $statusCode = 200): void
{
    http_response_code($statusCode);
    echo json_encode($payload, JSON_UNESCAPED_UNICODE);
    exit;
}

$mobile = trim((string) ($_POST['mobile'] ?? ''));

if (!preg_match('/^09\d{9}$/', $mobile)) {
    jsonResponse([
        'success' => false,
        'message' => 'شماره موبایل معتبر نیست.',
    ], 422);
}

$otp = (string) random_int(100000, 999999);
$expiresAt = time() + 120;

$storePath = __DIR__ . '/otp_store.json';
$store = [];

if (file_exists($storePath)) {
    $raw = file_get_contents($storePath);
    $decoded = json_decode((string) $raw, true);
    if (is_array($decoded)) {
        $store = $decoded;
    }
}

$store[$mobile] = [
    'otp' => $otp,
    'expires_at' => $expiresAt,
];

file_put_contents($storePath, json_encode($store, JSON_UNESCAPED_UNICODE));

$result = SmsService::sendOtp($mobile, $otp);

if (!$result['success']) {
    jsonResponse([
        'success' => false,
        'message' => $result['message'] ?? 'ارسال کد تایید ناموفق بود.',
    ], 500);
}

jsonResponse([
    'success' => true,
    'message' => 'کد تایید با موفقیت ارسال شد.',
]);
