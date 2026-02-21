<?php

declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');

function jsonResponse(array $payload, int $statusCode = 200): void
{
    http_response_code($statusCode);
    echo json_encode($payload, JSON_UNESCAPED_UNICODE);
    exit;
}

$mobile = trim((string) ($_POST['mobile'] ?? ''));
$otp = trim((string) ($_POST['otp'] ?? ''));

if (!preg_match('/^09\d{9}$/', $mobile)) {
    jsonResponse([
        'success' => false,
        'message' => 'شماره موبایل معتبر نیست.',
    ], 422);
}

if (!preg_match('/^\d{4,6}$/', $otp)) {
    jsonResponse([
        'success' => false,
        'message' => 'کد تایید معتبر نیست.',
    ], 422);
}

$storePath = __DIR__ . '/otp_store.json';
if (!file_exists($storePath)) {
    jsonResponse([
        'success' => false,
        'message' => 'کدی برای این شماره ارسال نشده است.',
    ], 404);
}

$raw = file_get_contents($storePath);
$store = json_decode((string) $raw, true);
if (!is_array($store) || !isset($store[$mobile])) {
    jsonResponse([
        'success' => false,
        'message' => 'کدی برای این شماره ارسال نشده است.',
    ], 404);
}

$record = $store[$mobile];
$savedOtp = (string) ($record['otp'] ?? '');
$expiresAt = (int) ($record['expires_at'] ?? 0);

if ($expiresAt < time()) {
    unset($store[$mobile]);
    file_put_contents($storePath, json_encode($store, JSON_UNESCAPED_UNICODE));

    jsonResponse([
        'success' => false,
        'message' => 'کد تایید منقضی شده است.',
    ], 410);
}

if (!hash_equals($savedOtp, $otp)) {
    jsonResponse([
        'success' => false,
        'message' => 'کد تایید نادرست است.',
    ], 401);
}

unset($store[$mobile]);
file_put_contents($storePath, json_encode($store, JSON_UNESCAPED_UNICODE));

jsonResponse([
    'success' => true,
    'message' => 'تایید انجام شد.',
    'token' => base64_encode($mobile . '|' . time()),
]);
