--Типовые запросы

-- 1. Вывод всех товаров в категории
SELECT * FROM Product WHERE category_id = 1;

-- 2. Вывод всех заказов пользователя
SELECT * FROM Orders
WHERE user_id = 2;

-- 3. Вывод общей суммы заказов за определенный период
SELECT SUM(quantity * price) as total_sum
FROM OrderDetails
WHERE order_id IN (SELECT id FROM Orders
				   WHERE created_at 
				   BETWEEN '2024-04-01' AND '2024-04-07');

-- 4. Вывод списка пользователей, сделавших заказ в определенный период
SELECT * FROM Users
WHERE id IN (SELECT DISTINCT user_id 
			 FROM Orders WHERE created_at 
			 BETWEEN '2024-04-01' AND '2024-04-07');
 

-- 5. Вывод списка товаров, которые не были проданы за определенный период
	SELECT * FROM Product 
	WHERE id NOT IN(SELECT product_id 
					FROM OrderDetails
					WHERE order_id IN (SELECT id FROM Orders 
									   WHERE created_at
									   BETWEEN '2024-03-16' AND '2024-03-31'));

-- 6. Вывод списка отзывов о товаре
SELECT * FROM Review
WHERE product_id = 1

-- 7. Вывод всех товаров в корзине пользователя
SELECT Product.*, CartDetails.quantity
FROM CartDetails
JOIN Product ON Product.id = CartDetails.product_id
WHERE CartDetails.cart_id = 1;

-- 8. Вывод общей суммы товаров в корзине
SELECT SUM(quantity * price) as total_sum
FROM CartDetails WHERE cart_id = 1;