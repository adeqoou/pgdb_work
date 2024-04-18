-- Хранимые процедуры

-- 1. Добавление отзыва к товару:
CREATE OR REPLACE FUNCTION add_review(n_product_id INTEGER, n_user_id INTEGER, n_rating INTEGER, n_comment TEXT)
RETURNS VOID AS $$
BEGIN
    INSERT INTO Review (product_id, user_id, rating, comment, created_at)
    VALUES (n_product_id, n_user_id, n_rating, n_comment, NOW());
	
	-- Если надо вызвать
	--SELECT add_review(1, 2, 5, 'Товар отличный, покупаю не в первый раз');
	
	COMMIT;
END;
$$ LANGUAGE plpgsql;


-- 2. Добавление товаров в корзину:
CREATE OR REPLACE FUNCTION add_to_cart(p_user_id INTEGER, p_product_id INTEGER, p_quantity INTEGER)
RETURNS VOID AS $$
DECLARE
	cart_id INTEGER;
	product_price DECIMAL(10, 2);
BEGIN
	SELECT id INTO cart_id FROM Cart WHERE user_id = p_user_id;

	IF cart_id IS NULL THEN
		INSERT INTO Cart(user_id, created_at, updated_at)
		VALUES (p_user_id, NOW(), NOW()) RETURNING id INTO cart_id;
	END IF;

	SELECT price INTO product_price FROM Product WHERE id = p_product_id;

	INSERT INTO CartDetails (quantity, price, product_id, cart_id)
	VALUES (p_quantity, product_price, p_product_id, cart_id);
	
	COMMIT;
END;
$$ LANGUAGE plpgsql;


-- 3. Удаление товаров из корзины:
CREATE OR REPLACE FUNCTION remove_from_cart(p_user_id INTEGER, p_product_id INTEGER)
RETURNS VOID AS $$
DECLARE
    p_cart_id INTEGER;   
BEGIN
    -- Проверка, существует ли уже корзина для пользователя
    SELECT id INTO p_cart_id FROM Cart WHERE user_id = p_user_id;

    -- Если корзины нет, выводим сообщение об ошибке
    IF p_cart_id IS NULL THEN
        RAISE NOTICE 'Корзина не найдена';
        RETURN;
    END IF;

    -- Удаляем товар из корзины
    DELETE FROM CartDetails WHERE cart_id = p_cart_id AND product_id = p_product_id;
	
	COMMIT;
END;
$$ LANGUAGE plpgsql;

