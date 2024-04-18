-- Транзакции

-- 1. Создание заказа и добавление товаров в него
DO $$
DECLARE
  order_id INTEGER;
BEGIN
  -- Создание нового заказа
  INSERT INTO Orders (status, user_id, created_at, updated_at)
  VALUES ('Не оплачено', 1, NOW(), NOW())
  RETURNING id INTO order_id;

  -- Добавление товаров в заказ
  INSERT INTO OrderDetails (order_id, product_id, quantity, price)
  VALUES
  (order_id, 1, 2, 1299.00),
  (order_id, 2, 1, 5000.00);

COMMIT;

END;
$$;


-- 2. Добавление отзыва к товару
BEGIN;

INSERT INTO Review (rate, comment, created_at, user_id, product_id)
VALUES
(4.5, 'Товар очень понравился, привезли быстро', NOW(), 2, 1),
(2.2, 'Худи не подошел, размер не тот', NOW(), 4, 1);

COMMIT;


-- 3. Добавление товаров в корзину
DO $$
DECLARE
    cart_id INTEGER;
BEGIN
    -- Проверяем, существует ли уже корзина для пользователя
    SELECT id INTO cart_id FROM Cart WHERE user_id = 2;

    -- Если корзины нет, создаем новую
    IF NOT FOUND THEN
        INSERT INTO Cart (user_id, created_at, updated_at)
		VALUES (2, NOW(), NOW())
		RETURNING id INTO cart_id;
    END IF;

    -- Добавляем товар в корзину
    INSERT INTO CartDetails (cart_id, product_id, quantity, price)
	VALUES (cart_id, 1, 2, 1299.00);
	
	COMMIT ; 
END;
$$;

-- 4. Удаление товаров из корзины
BEGIN;

DELETE FROM CartDetails WHERE cart_id = 1 AND product_id = 1;

COMMIT;
