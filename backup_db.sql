PGDMP                      |            shop_db    16.1    16.1 f    `           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            a           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            b           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            c           1262    35010    shop_db    DATABASE     {   CREATE DATABASE shop_db WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Russian_Russia.1251';
    DROP DATABASE shop_db;
                postgres    false            d           0    0    DATABASE shop_db    ACL     (   GRANT ALL ON DATABASE shop_db TO admin;
                   postgres    false    4963            �            1255    36441 +   add_review(integer, integer, integer, text)    FUNCTION     �  CREATE FUNCTION public.add_review(n_product_id integer, n_user_id integer, n_rating integer, n_comment text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO Review (product_id, user_id, rating, comment, created_at)
    VALUES (n_product_id, n_user_id, n_rating, n_comment, NOW());
	
	-- Если надо вызвать
	--SELECT add_review(1, 2, 5, 'Товар отличный, покупаю не в первый раз');
	
	COMMIT;
END;
$$;
 l   DROP FUNCTION public.add_review(n_product_id integer, n_user_id integer, n_rating integer, n_comment text);
       public          postgres    false            �            1255    36444 &   add_to_cart(integer, integer, integer)    FUNCTION     v  CREATE FUNCTION public.add_to_cart(p_user_id integer, p_product_id integer, p_quantity integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
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
$$;
 _   DROP FUNCTION public.add_to_cart(p_user_id integer, p_product_id integer, p_quantity integer);
       public          postgres    false            �            1255    36432 !   calculate_average_rating(integer)    FUNCTION       CREATE FUNCTION public.calculate_average_rating(product_id integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
	avg_rating DECIMAL(3, 2);
BEGIN
	SELECT AVG(r.review) INTO avg_rating
	FROM Review AS r
	WHERE r.product_id = product_id;
	
	RETURN avg_rating;
END;
$$;
 C   DROP FUNCTION public.calculate_average_rating(product_id integer);
       public          postgres    false            �            1255    36431    calculate_total_price(integer)    FUNCTION     4  CREATE FUNCTION public.calculate_total_price(order_id integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
    total_price DECIMAL(10, 2);
BEGIN
    SELECT SUM(od.quantity * od.price) INTO total_price
    FROM OrderDetails AS od
    WHERE od.order_id = order_id;

    RETURN total_price;
END;
$$;
 >   DROP FUNCTION public.calculate_total_price(order_id integer);
       public          postgres    false            �            1255    36435 0   create_order(integer, integer, integer, integer)    FUNCTION     �  CREATE FUNCTION public.create_order(o_order_id integer, o_product_id integer, o_quantity integer, o_user_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
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
$$;
 t   DROP FUNCTION public.create_order(o_order_id integer, o_product_id integer, o_quantity integer, o_user_id integer);
       public          postgres    false            �            1255    36447 9   existing_review(integer, double precision, integer, text)    FUNCTION     4  CREATE FUNCTION public.existing_review(r_product_id integer, r_rating double precision, r_user_id integer, r_comment text) RETURNS void
    LANGUAGE plpgsql
    AS $$
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
$$;
 z   DROP FUNCTION public.existing_review(r_product_id integer, r_rating double precision, r_user_id integer, r_comment text);
       public          postgres    false            �            1255    36446 "   remove_from_cart(integer, integer)    FUNCTION     �  CREATE FUNCTION public.remove_from_cart(p_user_id integer, p_product_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
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
$$;
 P   DROP FUNCTION public.remove_from_cart(p_user_id integer, p_product_id integer);
       public          postgres    false            �            1255    36437    update_product_quantity()    FUNCTION     �   CREATE FUNCTION public.update_product_quantity() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	UPDATE Product SET quantity = quantity - NEW.quantity
	WHERE id = NEW.product_id;
	RETURN NEW;
END;
$$;
 0   DROP FUNCTION public.update_product_quantity();
       public          postgres    false            �            1255    36427 !   update_product_quantity_in_cart()    FUNCTION     o  CREATE FUNCTION public.update_product_quantity_in_cart() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;
 8   DROP FUNCTION public.update_product_quantity_in_cart();
       public          postgres    false            �            1259    36319    cart    TABLE     �   CREATE TABLE public.cart (
    id integer NOT NULL,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);
    DROP TABLE public.cart;
       public         heap    postgres    false            e           0    0 
   TABLE cart    ACL     �   GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.cart TO admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.cart TO customer;
GRANT SELECT ON TABLE public.cart TO manager;
          public          postgres    false    230            �            1259    36318    cart_id_seq    SEQUENCE     �   CREATE SEQUENCE public.cart_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 "   DROP SEQUENCE public.cart_id_seq;
       public          postgres    false    230            f           0    0    cart_id_seq    SEQUENCE OWNED BY     ;   ALTER SEQUENCE public.cart_id_seq OWNED BY public.cart.id;
          public          postgres    false    229            �            1259    36331    cartdetails    TABLE     �   CREATE TABLE public.cartdetails (
    id integer NOT NULL,
    quantity integer,
    price numeric(10,2),
    product_id integer,
    cart_id integer,
    CONSTRAINT cartdetails_quantity_check CHECK ((quantity > 0))
);
    DROP TABLE public.cartdetails;
       public         heap    postgres    false            g           0    0    TABLE cartdetails    ACL     �   GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.cartdetails TO admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.cartdetails TO customer;
GRANT SELECT ON TABLE public.cartdetails TO manager;
          public          postgres    false    232            �            1259    36330    cartdetails_id_seq    SEQUENCE     �   CREATE SEQUENCE public.cartdetails_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.cartdetails_id_seq;
       public          postgres    false    232            h           0    0    cartdetails_id_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.cartdetails_id_seq OWNED BY public.cartdetails.id;
          public          postgres    false    231            �            1259    36219    category    TABLE     q   CREATE TABLE public.category (
    id integer NOT NULL,
    name character varying(255),
    description text
);
    DROP TABLE public.category;
       public         heap    postgres    false            i           0    0    TABLE category    ACL     �   GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.category TO admin;
GRANT SELECT ON TABLE public.category TO customer;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.category TO manager;
          public          postgres    false    216            �            1259    36218    category_id_seq    SEQUENCE     �   CREATE SEQUENCE public.category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.category_id_seq;
       public          postgres    false    216            j           0    0    category_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.category_id_seq OWNED BY public.category.id;
          public          postgres    false    215            �            1259    36281    orderdetails    TABLE     �   CREATE TABLE public.orderdetails (
    id integer NOT NULL,
    quantity integer,
    price numeric(10,2),
    order_id integer,
    product_id integer,
    CONSTRAINT orderdetails_quantity_check CHECK ((quantity > 0))
);
     DROP TABLE public.orderdetails;
       public         heap    postgres    false            k           0    0    TABLE orderdetails    ACL     �   GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.orderdetails TO admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.orderdetails TO customer;
GRANT SELECT,UPDATE ON TABLE public.orderdetails TO manager;
          public          postgres    false    226            �            1259    36280    orderdetails_id_seq    SEQUENCE     �   CREATE SEQUENCE public.orderdetails_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.orderdetails_id_seq;
       public          postgres    false    226            l           0    0    orderdetails_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.orderdetails_id_seq OWNED BY public.orderdetails.id;
          public          postgres    false    225            �            1259    36269    orders    TABLE     �   CREATE TABLE public.orders (
    id integer NOT NULL,
    status character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer
);
    DROP TABLE public.orders;
       public         heap    postgres    false            m           0    0    TABLE orders    ACL     �   GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.orders TO admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.orders TO customer;
GRANT SELECT,UPDATE ON TABLE public.orders TO manager;
          public          postgres    false    224            �            1259    36268    orders_id_seq    SEQUENCE     �   CREATE SEQUENCE public.orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.orders_id_seq;
       public          postgres    false    224            n           0    0    orders_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;
          public          postgres    false    223            �            1259    36228    product    TABLE     >  CREATE TABLE public.product (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    price numeric(10,2) NOT NULL,
    quantity integer NOT NULL,
    images character varying(255) NOT NULL,
    category_id integer,
    CONSTRAINT product_quantity_check CHECK ((quantity > 0))
);
    DROP TABLE public.product;
       public         heap    postgres    false            o           0    0    TABLE product    ACL     �   GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.product TO admin;
GRANT SELECT ON TABLE public.product TO customer;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.product TO manager;
          public          postgres    false    218            �            1259    36227    product_id_seq    SEQUENCE     �   CREATE SEQUENCE public.product_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.product_id_seq;
       public          postgres    false    218            p           0    0    product_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.product_id_seq OWNED BY public.product.id;
          public          postgres    false    217            �            1259    36299    review    TABLE     F  CREATE TABLE public.review (
    id integer NOT NULL,
    rating double precision NOT NULL,
    comment text,
    created_at timestamp without time zone NOT NULL,
    user_id integer,
    product_id integer,
    CONSTRAINT review_rate_check CHECK (((rating >= (0)::double precision) AND (rating <= (5)::double precision)))
);
    DROP TABLE public.review;
       public         heap    postgres    false            q           0    0    TABLE review    ACL     �   GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.review TO admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.review TO customer;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.review TO manager;
          public          postgres    false    228            �            1259    36252    users    TABLE     U  CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    role_id integer,
    images character varying(255)
);
    DROP TABLE public.users;
       public         heap    postgres    false            r           0    0    TABLE users    ACL     B   GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.users TO admin;
          public          postgres    false    222            �            1259    36402    product_review    VIEW     #  CREATE VIEW public.product_review AS
 SELECT r.id,
    r.rating,
    r.comment,
    r.created_at,
    r.product_id,
    r.user_id,
    p.title,
    u.username
   FROM ((public.review r
     JOIN public.users u ON ((u.id = r.user_id)))
     JOIN public.product p ON ((r.product_id = p.id)));
 !   DROP VIEW public.product_review;
       public          postgres    false    228    228    218    228    228    228    228    222    222    218            �            1259    36298    review_id_seq    SEQUENCE     �   CREATE SEQUENCE public.review_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.review_id_seq;
       public          postgres    false    228            s           0    0    review_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.review_id_seq OWNED BY public.review.id;
          public          postgres    false    227            �            1259    36243    role    TABLE     v   CREATE TABLE public.role (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text
);
    DROP TABLE public.role;
       public         heap    postgres    false            t           0    0 
   TABLE role    ACL     A   GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.role TO admin;
          public          postgres    false    220            �            1259    36242    role_id_seq    SEQUENCE     �   CREATE SEQUENCE public.role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 "   DROP SEQUENCE public.role_id_seq;
       public          postgres    false    220            u           0    0    role_id_seq    SEQUENCE OWNED BY     ;   ALTER SEQUENCE public.role_id_seq OWNED BY public.role.id;
          public          postgres    false    219            �            1259    36379    user_orders    VIEW     �  CREATE VIEW public.user_orders AS
 SELECT o.id,
    o.user_id,
    o.created_at,
    o.updated_at,
    o.status,
    p.id AS product_id,
    p.title,
    p.price,
    u.username,
    od.quantity
   FROM (((public.orders o
     JOIN public.orderdetails od ON ((od.order_id = o.id)))
     JOIN public.product p ON ((od.product_id = p.id)))
     JOIN public.users u ON ((u.id = o.user_id)));
    DROP VIEW public.user_orders;
       public          postgres    false    218    218    218    222    222    224    224    224    224    224    226    226    226            �            1259    36411    user_products    VIEW     �  CREATE VIEW public.user_products AS
 SELECT cd.id,
    cd.price,
    cd.quantity,
    cd.product_id,
    cd.cart_id,
    p.title,
    c.created_at,
    c.updated_at,
    c.user_id,
    u.username
   FROM (((public.cart c
     JOIN public.cartdetails cd ON ((cd.cart_id = c.id)))
     JOIN public.product p ON ((cd.product_id = p.id)))
     JOIN public.users u ON ((c.user_id = u.id)));
     DROP VIEW public.user_products;
       public          postgres    false    232    218    218    222    222    230    230    230    230    232    232    232    232            �            1259    36251    users_id_seq    SEQUENCE     �   CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.users_id_seq;
       public          postgres    false    222            v           0    0    users_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;
          public          postgres    false    221            �           2604    36322    cart id    DEFAULT     b   ALTER TABLE ONLY public.cart ALTER COLUMN id SET DEFAULT nextval('public.cart_id_seq'::regclass);
 6   ALTER TABLE public.cart ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    229    230    230            �           2604    36334    cartdetails id    DEFAULT     p   ALTER TABLE ONLY public.cartdetails ALTER COLUMN id SET DEFAULT nextval('public.cartdetails_id_seq'::regclass);
 =   ALTER TABLE public.cartdetails ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    232    231    232            �           2604    36222    category id    DEFAULT     j   ALTER TABLE ONLY public.category ALTER COLUMN id SET DEFAULT nextval('public.category_id_seq'::regclass);
 :   ALTER TABLE public.category ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    215    216    216            �           2604    36284    orderdetails id    DEFAULT     r   ALTER TABLE ONLY public.orderdetails ALTER COLUMN id SET DEFAULT nextval('public.orderdetails_id_seq'::regclass);
 >   ALTER TABLE public.orderdetails ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    225    226    226            �           2604    36272 	   orders id    DEFAULT     f   ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);
 8   ALTER TABLE public.orders ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    224    223    224            �           2604    36231 
   product id    DEFAULT     h   ALTER TABLE ONLY public.product ALTER COLUMN id SET DEFAULT nextval('public.product_id_seq'::regclass);
 9   ALTER TABLE public.product ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    218    217    218            �           2604    36302 	   review id    DEFAULT     f   ALTER TABLE ONLY public.review ALTER COLUMN id SET DEFAULT nextval('public.review_id_seq'::regclass);
 8   ALTER TABLE public.review ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    228    227    228            �           2604    36246    role id    DEFAULT     b   ALTER TABLE ONLY public.role ALTER COLUMN id SET DEFAULT nextval('public.role_id_seq'::regclass);
 6   ALTER TABLE public.role ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    219    220    220            �           2604    36255    users id    DEFAULT     d   ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);
 7   ALTER TABLE public.users ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    222    221    222            [          0    36319    cart 
   TABLE DATA           C   COPY public.cart (id, user_id, created_at, updated_at) FROM stdin;
    public          postgres    false    230   (�       ]          0    36331    cartdetails 
   TABLE DATA           O   COPY public.cartdetails (id, quantity, price, product_id, cart_id) FROM stdin;
    public          postgres    false    232   ��       M          0    36219    category 
   TABLE DATA           9   COPY public.category (id, name, description) FROM stdin;
    public          postgres    false    216   ��       W          0    36281    orderdetails 
   TABLE DATA           Q   COPY public.orderdetails (id, quantity, price, order_id, product_id) FROM stdin;
    public          postgres    false    226   �       U          0    36269    orders 
   TABLE DATA           M   COPY public.orders (id, status, created_at, updated_at, user_id) FROM stdin;
    public          postgres    false    224   c�       O          0    36228    product 
   TABLE DATA           _   COPY public.product (id, title, description, price, quantity, images, category_id) FROM stdin;
    public          postgres    false    218   ˈ       Y          0    36299    review 
   TABLE DATA           V   COPY public.review (id, rating, comment, created_at, user_id, product_id) FROM stdin;
    public          postgres    false    228   Ή       Q          0    36243    role 
   TABLE DATA           5   COPY public.role (id, name, description) FROM stdin;
    public          postgres    false    220   Ҋ       S          0    36252    users 
   TABLE DATA           f   COPY public.users (id, username, email, password, first_name, last_name, role_id, images) FROM stdin;
    public          postgres    false    222   ��       w           0    0    cart_id_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.cart_id_seq', 12, true);
          public          postgres    false    229            x           0    0    cartdetails_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.cartdetails_id_seq', 13, true);
          public          postgres    false    231            y           0    0    category_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.category_id_seq', 4, true);
          public          postgres    false    215            z           0    0    orderdetails_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.orderdetails_id_seq', 18, true);
          public          postgres    false    225            {           0    0    orders_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.orders_id_seq', 11, true);
          public          postgres    false    223            |           0    0    product_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.product_id_seq', 2, true);
          public          postgres    false    217            }           0    0    review_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.review_id_seq', 20, true);
          public          postgres    false    227            ~           0    0    role_id_seq    SEQUENCE SET     9   SELECT pg_catalog.setval('public.role_id_seq', 3, true);
          public          postgres    false    219                       0    0    users_id_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.users_id_seq', 4, true);
          public          postgres    false    221            �           2606    36324    cart cart_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY public.cart DROP CONSTRAINT cart_pkey;
       public            postgres    false    230            �           2606    36337    cartdetails cartdetails_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.cartdetails
    ADD CONSTRAINT cartdetails_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.cartdetails DROP CONSTRAINT cartdetails_pkey;
       public            postgres    false    232            �           2606    36226    category category_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.category
    ADD CONSTRAINT category_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.category DROP CONSTRAINT category_pkey;
       public            postgres    false    216            �           2606    36287    orderdetails orderdetails_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.orderdetails
    ADD CONSTRAINT orderdetails_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.orderdetails DROP CONSTRAINT orderdetails_pkey;
       public            postgres    false    226            �           2606    36274    orders orders_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.orders DROP CONSTRAINT orders_pkey;
       public            postgres    false    224            �           2606    36236    product product_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.product DROP CONSTRAINT product_pkey;
       public            postgres    false    218            �           2606    36307    review review_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.review
    ADD CONSTRAINT review_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.review DROP CONSTRAINT review_pkey;
       public            postgres    false    228            �           2606    36250    role role_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY public.role DROP CONSTRAINT role_pkey;
       public            postgres    false    220            �           2606    36261    users users_email_key 
   CONSTRAINT     Q   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);
 ?   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key;
       public            postgres    false    222            �           2606    36259    users users_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.users DROP CONSTRAINT users_pkey;
       public            postgres    false    222            �           2620    36438 "   orderdetails update_product_amount    TRIGGER     �   CREATE TRIGGER update_product_amount AFTER INSERT ON public.orderdetails FOR EACH ROW EXECUTE FUNCTION public.update_product_quantity();
 ;   DROP TRIGGER update_product_amount ON public.orderdetails;
       public          postgres    false    226    252            �           2620    36428    cartdetails update_quantity    TRIGGER     �   CREATE TRIGGER update_quantity AFTER INSERT OR DELETE ON public.cartdetails FOR EACH ROW EXECUTE FUNCTION public.update_product_quantity_in_cart();
 4   DROP TRIGGER update_quantity ON public.cartdetails;
       public          postgres    false    232    236            �           2606    36325    cart cart_user_id_fkey    FK CONSTRAINT     u   ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
 @   ALTER TABLE ONLY public.cart DROP CONSTRAINT cart_user_id_fkey;
       public          postgres    false    4771    222    230            �           2606    36343 $   cartdetails cartdetails_cart_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.cartdetails
    ADD CONSTRAINT cartdetails_cart_id_fkey FOREIGN KEY (cart_id) REFERENCES public.cart(id);
 N   ALTER TABLE ONLY public.cartdetails DROP CONSTRAINT cartdetails_cart_id_fkey;
       public          postgres    false    4779    232    230            �           2606    36338 '   cartdetails cartdetails_product_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.cartdetails
    ADD CONSTRAINT cartdetails_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.product(id);
 Q   ALTER TABLE ONLY public.cartdetails DROP CONSTRAINT cartdetails_product_id_fkey;
       public          postgres    false    218    4765    232            �           2606    36288 '   orderdetails orderdetails_order_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.orderdetails
    ADD CONSTRAINT orderdetails_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id);
 Q   ALTER TABLE ONLY public.orderdetails DROP CONSTRAINT orderdetails_order_id_fkey;
       public          postgres    false    4773    224    226            �           2606    36293 )   orderdetails orderdetails_product_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.orderdetails
    ADD CONSTRAINT orderdetails_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.product(id);
 S   ALTER TABLE ONLY public.orderdetails DROP CONSTRAINT orderdetails_product_id_fkey;
       public          postgres    false    218    4765    226            �           2606    36275    orders orders_user_id_fkey    FK CONSTRAINT     y   ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
 D   ALTER TABLE ONLY public.orders DROP CONSTRAINT orders_user_id_fkey;
       public          postgres    false    4771    222    224            �           2606    36237     product product_category_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.category(id);
 J   ALTER TABLE ONLY public.product DROP CONSTRAINT product_category_id_fkey;
       public          postgres    false    216    218    4763            �           2606    36313    review review_product_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.review
    ADD CONSTRAINT review_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.product(id);
 G   ALTER TABLE ONLY public.review DROP CONSTRAINT review_product_id_fkey;
       public          postgres    false    228    218    4765            �           2606    36308    review review_user_id_fkey    FK CONSTRAINT     y   ALTER TABLE ONLY public.review
    ADD CONSTRAINT review_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
 D   ALTER TABLE ONLY public.review DROP CONSTRAINT review_user_id_fkey;
       public          postgres    false    222    228    4771            �           2606    36262    users users_role_id_fkey    FK CONSTRAINT     v   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.role(id);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_role_id_fkey;
       public          postgres    false    222    4767    220            [   I   x�����0k3��?0�d�9�2��HםN��A���	�W�k�r;7J8�g	~�9q5VG*3�j��Vy �!X      ]   )   x�3�4�44���30�4�4�2�4�4500 �2\1z\\\ i]P      M   R   x�3�0�[/l�8/̾��bӅ��/�+\؇��2)�x��¦�=�f]�p����xP�^ � �U����� �0<      W   7   x�3�4�44���30�4�4�bNS��7�4��sr� ���b���� e
      U   X   x�3�0��V��.쿰����^�{a������*Z�X[�����2��y&\F��3S04�22�24�oP� �0L�      O   �   x�=�1N�0��9E.�߳�8	3+��%1N�&Q�(�!1T�����p���A��=����]l�e��Mc��M����E��9�o�ptp{#"Gd�_���=Ǒ۪5��rm�n����;�m�{�u��X�(`R`�@<E~�-��7�p�)��W�ы�<�����v!��1��=���OȄ̲�����wuSo���$Rw�	��A(]�4��H�P�L�(�P�L9"��A� {lN      Y   �   x��PKN�0\;���e��m��p�4,@��%R�iԨF���݈q
bW!�I��y~�D�����<!��j�zm�x�w�'�P7!5i�$�u#&Tbj'��}Ĩ;�0[�1Z�-,�8rF�,�2znd}�E�T���ǯ��Œi�%�@���VD�d"#N��-�\|�xrb�U�&��}�.i(Y������5�"s\�1��"x��?9ٖv��ci����l��l�ڋl�Uܻ�����L      Q   �   x�}PI
�@<g^1�����f��QH�^MD/�'���d��?��+x�骩�馡,Ǟأ��BZ�&����(@�LR��Hq�W��U�S�N�s�w�dc�R��+�\�^��-9mi͒ã{�3�jb#&��hÙ�O�~G���Q�oVgW��{�칖v��I�����65Q�������Z��2N�6�\N	Š!��A���      S   �   x�M�?n�P�g�0H/T��:u�C;���
Q^�!�R��;���(M�Bg07�2��ϲ?0��]�f�7�B#���� d!���sY˾	�6>˧|�N��a��b`�Z�!�|��J�08�/A��W1�
h���Z�������+Хh�v��P�]˜�����J�6rP�/��-�R�k�Ӱ??�7� [��������D7\�O�.�D��|�X�̗�SY'���E�?Gr�m     