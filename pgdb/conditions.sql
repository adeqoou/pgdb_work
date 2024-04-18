-- Условия

-- 1. Проверка наличия товара на складе перед добавлением его в заказ:
DO $$
DECLARE
    product_quantity INTEGER;
BEGIN

    SELECT quantity INTO product_quantity FROM Product WHERE id = 1;

    IF product_quantity >= 1 THEN

        INSERT INTO OrderDetails (quantity, price, order_id, product_id)
        VALUES (2, 1299.00, 2, 1);

        UPDATE Product SET quantity = quantity - 2 WHERE id = 1;

    ELSE
        RAISE NOTICE 'Недостаточно товаров на складе';
    END IF;

    COMMIT;
END $$;


-- 2. Проверка наличия товара на складе перед добавлением его в корзину:
DO $$
DECLARE 
	product_quantity INTEGER;
BEGIN

SELECT quantity INTO product_quantity FROM Product WHERE id = 2;

IF product_quantity >= 1 THEN
    IF EXISTS(SELECT * FROM CartDetails WHERE cart_id = 1 AND product_id = 2) THEN
	
        UPDATE CartDetails SET quantity = quantity + 1 WHERE cart_id = 1 AND product_id = 2;
    ELSE
        INSERT INTO CartDetails (cart_id, product_id, quantity, price) 
		VALUES (1, 2, 1, 5000.00);
    END IF;
ELSE
    RAISE NOTICE 'Недостаточно товара на складе';
END IF;

COMMIT;
END;
$$;
