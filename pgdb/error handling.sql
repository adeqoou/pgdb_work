-- Обработчики исключений

-- 1. Обработка ошибки при создании заказа, если товар отсутствует на складе:
CREATE OR REPLACE FUNCTION create_order(o_order_id INTEGER, o_product_id INTEGER, 
					o_quantity INTEGER, o_user_id INTEGER)
RETURNS VOID AS $$
DECLARE
	product_quantity INTEGER;
BEGIN 
	SELECT quantity INTO product_quantity
	FROM Product 
	WHERE id = o_product_id;
	
	IF product_quantity < o_quantity THEN
		RAISE EXCEPTION 'Недостаточное количество товаров на складе';
	ELSE
		INSERT INTO Orders (created_at, updated_at, user_id)
		VALUES (NOW(), NOW(), o_user_id);
		
		INSERT INTO OrderDetails (quantity, product_id, order_id)
		VALUES (o_quantity, o_product_id, o_order_id);
		
		UPDATE Product SET quantity = product_quantity - quantity
		WHERE id = o_product_id;
	END IF;	
END;
$$ LANGUAGE plpgsql;


-- 2. Обработка ошибки при добавлении отзыва, если он уже существует:
CREATE OR REPLACE FUNCTION existing_review(r_product_id INTEGER, r_rating FLOAT, r_user_id INTEGER, r_comment TEXT)
RETURNS VOID AS $$
DECLARE review_exists BOOLEAN;
BEGIN
	SELECT EXISTS(SELECT 1 FROM Review WHERE product_id = r_product_id AND user_id = r_user_id) 
	INTO review_exists;
	
	IF review_exists THEN
		RAISE EXCEPTION 'Отзыв уже существует';
	ELSE
		INSERT INTO Review (rating, comment, created_at, product_id, user_id)
		VALUES (r_rating, r_comment, NOW(), r_product_id, r_user_id);
	END IF;
END;
$$ LANGUAGE plpgsql;

-- Вызов функции 
-- SELECT add_review(r_product_id => 2, r_user_id => 2, r_rating => 4.5, r_comment => 'Хороший товар');
	