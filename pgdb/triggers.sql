-- Триггеры

-- 1. обновление количества товара на складе после создания заказа
CREATE OR REPLACE FUNCTION update_product_quantity()
RETURNS TRIGGER AS $$
BEGIN
	UPDATE Product SET quantity = quantity - NEW.quantity
	WHERE id = NEW.product_id;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_product_amount
AFTER INSERT ON OrderDetails
FOR EACH ROW
EXECUTE FUNCTION update_product_quantity();


 -- 2. обновление количества товаров в корзине после добавления или удаления товаров:
CREATE OR REPLACE FUNCTION update_product_quantity_in_cart()
RETURNS TRIGGER AS $$
DECLARE
	new_product_quantity INTEGER;
BEGIN
	SELECT SUM(cd.quantity) INTO new_product_quantity
	FROM CartDetails AS cd
	WHERE cd.cart_id = NEW.cart_id;
	
	UPDATE CartDetails SET quantity = new_product_quantity
	WHERE cart_id = NEW.cart_id;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_quantity
AFTER INSERT OR DELETE ON CartDetails
FOR EACH ROW
EXECUTE FUNCTION update_product_quantity_in_cart();
