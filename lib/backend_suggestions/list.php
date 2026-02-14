<?php
// my_api/billboards/list.php (improved)

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../core/Response.php';

$db = (new Database())->getConnection();

$where = ['b.is_active = 1'];
$params = [];

if (isset($_GET['province_id']) && $_GET['province_id'] !== '') {
    $where[] = 'b.province_id = :province_id';
    $params[':province_id'] = (int) $_GET['province_id'];
}

if (isset($_GET['city']) && $_GET['city'] !== '') {
    $where[] = 'b.city = :city';
    $params[':city'] = trim($_GET['city']);
}

if (isset($_GET['type']) && $_GET['type'] !== '') {
    $where[] = 'b.type = :type';
    $params[':type'] = trim($_GET['type']);
}

if (isset($_GET['search']) && $_GET['search'] !== '') {
    $where[] = '(b.area LIKE :search OR b.city LIKE :search OR b.code LIKE :search)';
    $params[':search'] = '%' . trim($_GET['search']) . '%';
}

if (isset($_GET['min_rent']) && $_GET['min_rent'] !== '') {
    $where[] = 'CAST(b.monthly_rent AS UNSIGNED) >= :min_rent';
    $params[':min_rent'] = (int) $_GET['min_rent'];
}

if (isset($_GET['max_rent']) && $_GET['max_rent'] !== '') {
    $where[] = 'CAST(b.monthly_rent AS UNSIGNED) <= :max_rent';
    $params[':max_rent'] = (int) $_GET['max_rent'];
}

$allowedSort = [
    'newest' => 'b.created_at DESC',
    'rent_asc' => 'CAST(b.monthly_rent AS UNSIGNED) ASC',
    'rent_desc' => 'CAST(b.monthly_rent AS UNSIGNED) DESC',
];
$sort = $_GET['sort'] ?? 'newest';
$orderBy = $allowedSort[$sort] ?? $allowedSort['newest'];

$limit = isset($_GET['limit']) ? (int) $_GET['limit'] : 20;
$limit = max(1, min($limit, 100));

$page = isset($_GET['page']) ? (int) $_GET['page'] : 1;
$page = max(1, $page);
$offset = ($page - 1) * $limit;

$whereSql = implode(' AND ', $where);

$countSql = "SELECT COUNT(*) FROM billboards b WHERE $whereSql";
$countStmt = $db->prepare($countSql);
foreach ($params as $key => $value) {
    $countStmt->bindValue($key, $value);
}
$countStmt->execute();
$total = (int) $countStmt->fetchColumn();

$sql = "SELECT
          b.id,
          b.province_id,
          p.name AS province_name,
          b.city,
          b.area,
          b.length,
          b.height,
          b.view,
          b.lighting,
          b.monthly_rent,
          b.phone,
          b.latitude,
          b.longitude,
          b.seller,
          b.image_url,
          b.code,
          b.type
        FROM billboards b
        LEFT JOIN provinces p ON p.id = b.province_id
        WHERE $whereSql
        ORDER BY $orderBy
        LIMIT :limit OFFSET :offset";

$stmt = $db->prepare($sql);
foreach ($params as $key => $value) {
    $stmt->bindValue($key, $value);
}
$stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
$stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
$stmt->execute();

$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

Response::json([
    'success' => true,
    'meta' => [
        'page' => $page,
        'limit' => $limit,
        'total' => $total,
    ],
    'data' => $rows,
]);
