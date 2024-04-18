--Локальные переменные

DO $$
DECLARE
  total_price NUMERIC(10, 2) := 0; -- Общая сумма заказа
  product_count INTEGER := 0; -- Количество товаров в заказе
  user_role TEXT := 'user'; -- Роль пользователя
  rating INTEGER := 5; -- Рейтинг товара
  comment TEXT := 'Отличный товар!'; -- Комментарий к товару
  user_id INTEGER := 2; -- id пользователя
  product_id INTEGER := 2; -- id товара
BEGIN
  -- Получение роли пользователя
  SELECT role_id
  INTO user_role
  FROM Users
  WHERE id = user_id;

  -- Добавление отзыва к товару
  INSERT INTO Review (product_id, user_id, rating, comment, created_at)
  VALUES (product_id, user_id, rating, comment, NOW());

  -- Добавление товара в корзину
  INSERT INTO Cart (user_id, created_at, updated_at)
  VALUES (user_id, NOW(), NOW());

  -- Подсчет общей суммы и количества товаров в заказе
  SELECT SUM(price * quantity) AS total, COUNT(*) AS count
  INTO total_price, product_count
  FROM OrderDetails
  WHERE order_id = 2;

  -- Вывод значений переменных
  RAISE NOTICE 'Total price: %, Product count: %', total_price, product_count;
  RAISE NOTICE 'User role: %', user_role;
  RAISE NOTICE 'Rating: %', rating;
  RAISE NOTICE 'Comment: %', comment;
END $$;
