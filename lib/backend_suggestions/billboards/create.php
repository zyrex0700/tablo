<?php
// my_api/billboards/create.php (PHP 7.4+ compatible)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, X-Requested-With, Authorization");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../core/Response.php';
require_once __DIR__ . '/../core/JwtHelper.php';

$db = (new Database())->getConnection();
$db->exec("SET NAMES utf8mb4");

/**
 * PHP 7.4 compatibility helper for str_starts_with (introduced in PHP 8).
 */
if (!function_exists('starts_with')) {
    function starts_with($haystack, $needle)
    {
        if ($needle === '') {
            return true;
        }

        return strpos($haystack, $needle) === 0;
    }
}

// 1) گرفتن توکن از هدر
$headers = function_exists('getallheaders') ? getallheaders() : [];
$authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? '';

if (!starts_with(trim($authHeader), 'Bearer ')) {
    Response::json([
        'success' => false,
        'message' => 'توکن ارسال نشده است',
    ], 401);
    exit;
}

$token = trim(substr($authHeader, 7));
$payload = JwtHelper::verifyToken($token);

if (!$payload || empty($payload['phone'])) {
    Response::json([
        'success' => false,
        'message' => 'توکن نامعتبر است',
    ], 401);
    exit;
}

$userPhone = $payload['phone'];

// 2) گرفتن داده‌ها از body
$raw = file_get_contents('php://input');
$data = json_decode($raw, true);

$province_id  = $data['province_id'] ?? null;
$city         = $data['city'] ?? '';
$area         = $data['area'] ?? '';
$height       = $data['height'] ?? null;
$length       = $data['length'] ?? null;
$view         = $data['view'] ?? '';
$lighting     = $data['lighting'] ?? '';
$monthly_rent = $data['monthly_rent'] ?? null;
$phone        = $data['phone'] ?? '';
$latitude     = $data['latitude'] ?? null;
$longitude    = $data['longitude'] ?? null;
$seller       = $data['seller'] ?? '';
$image_url    = $data['image_url'] ?? null;
$code         = $data['code'] ?? '';
$type         = $data['type'] ?? '';

if (empty($province_id) || empty($city) || empty($area)) {
    Response::json([
        'success' => false,
        'message' => 'استان، شهر و محور الزامی هستند',
    ], 422);
    exit;
}

$sql = "
    INSERT INTO billboards (
        province_id, city, area,
        height, length, view, lighting,
        monthly_rent, phone,
        latitude, longitude,
        seller, image_url,
        code, type,
        user_phone
    ) VALUES (
        :province_id, :city, :area,
        :height, :length, :view, :lighting,
        :monthly_rent, :phone,
        :latitude, :longitude,
        :seller, :image_url,
        :code, :type,
        :user_phone
    )
";

$stmt = $db->prepare($sql);
$stmt->execute([
    ':province_id'  => $province_id,
    ':city'         => $city,
    ':area'         => $area,
    ':height'       => $height,
    ':length'       => $length,
    ':view'         => $view,
    ':lighting'     => $lighting,
    ':monthly_rent' => $monthly_rent,
    ':phone'        => $phone,
    ':latitude'     => $latitude,
    ':longitude'    => $longitude,
    ':seller'       => $seller,
    ':image_url'    => $image_url,
    ':code'         => $code,
    ':type'         => $type,
    ':user_phone'   => $userPhone,
]);

$id = $db->lastInsertId();

Response::json([
    'success' => true,
    'id'      => (int)$id,
]);
