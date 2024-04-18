-- Представления

-- 1. Вывод всех заказов пользователя
CREATE VIEW user_orders AS
SELECT
	o.id, o.user_id, o.created_at, o.updated_at, o.status,
	p.id AS product_id, p.title, p.price,
	u.username,
	od.quantity
FROM Orders AS o
JOIN OrderDetails AS od ON od.order_id = o.id
JOIN Product AS p ON od.product_id = p.id
JOIN Users AS u ON u.id = o.user_id;


-- 2. Вывод отзывов о товаре
CREATE VIEW product_review AS
SELECT 
	r.id, r.rating, r.comment, r.created_at, r.product_id, r.user_id,
	p.title,
	u.username
FROM Review AS r
JOIN Users AS u ON u.id = r.user_id
JOIN Product AS p ON r.product_id = p.id;


-- 3. Вывод всех товаров в корзине пользователя
CREATE VIEW user_products AS
SELECT 
	cd.id, cd.price, cd.quantity, cd.product_id, cd.cart_id,
	p.title,
	c.created_at, c.updated_at, c.user_id,
	u.username
FROM Cart AS c
JOIN CartDetails AS cd ON cd.cart_id = c.id
JOIN Product AS p ON cd.product_id = p.id
JOIN Users AS u ON c.user_id = u.id;