-- Пользовательские функции

 -- 1. Создание функции для расчета общей суммы заказа:
CREATE OR REPLACE FUNCTION calculate_total_price(order_id INTEGER)
RETURNS DECIMAL(10, 2) AS $$
DECLARE
    total_price DECIMAL(10, 2);
BEGIN
    SELECT SUM(od.quantity * od.price) INTO total_price
    FROM OrderDetails AS od
    WHERE od.order_id = order_id;

    RETURN total_price;
END;
$$ LANGUAGE plpgsql; 


-- 2. Создание функции для расчета среднего рейтинга товара:
CREATE OR REPLACE FUNCTION calculate_average_rating(product_id INTEGER)
RETURNS DECIMAL(3, 2) AS $$
DECLARE
	avg_rating DECIMAL(3, 2);
BEGIN
	SELECT AVG(r.review) INTO avg_rating
	FROM Review AS r
	WHERE r.product_id = product_id;
	
	RETURN avg_rating; 
END;
$$ LANGUAGE plpgsql;