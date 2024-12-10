

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";






COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "wrappers" WITH SCHEMA "extensions";






CREATE OR REPLACE FUNCTION "public"."CR_CheckUserRole"("userid" "uuid", "roleid" "uuid") RETURNS boolean
    LANGUAGE "sql"
    AS $$select
  cast(
    case
      when exists (
        select
          1
        from
          public."userRoles"
        where
          public."userRoles"."userId" = UserId and public."userRoles"."roleId" = RoleId
      ) then true
      else false
    end as bool
  );$$;


ALTER FUNCTION "public"."CR_CheckUserRole"("userid" "uuid", "roleid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."CR_GetMyStore"() RETURNS "record"
    LANGUAGE "sql"
    AS $$select
  public."Store".*
from
  public."Store"
where
  public."Store"."GUID" = 'b7037a11-2fd2-4a1b-bcc7-a0870b24e4a8';$$;


ALTER FUNCTION "public"."CR_GetMyStore"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."CR_GetProduct"("productguid" "uuid") RETURNS "record"
    LANGUAGE "sql"
    AS $$select
  public."Product".*
from
  public."Product"
where
  public."Product"."GUID" = ProductGUID$$;


ALTER FUNCTION "public"."CR_GetProduct"("productguid" "uuid") OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."Product" (
    "Id" bigint NOT NULL,
    "GUID" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "StoreId" bigint NOT NULL,
    "Name" "text" NOT NULL,
    "Description" "text",
    "Dimensions" "text",
    "Color" "text",
    "NumberInStock" bigint DEFAULT '0'::bigint NOT NULL,
    "Price" numeric DEFAULT '0'::numeric NOT NULL,
    "Discount" numeric DEFAULT '0'::numeric,
    "IsActive" boolean DEFAULT true NOT NULL,
    "CreatedOn" timestamp with time zone DEFAULT "now"() NOT NULL,
    "UpdatedOn" timestamp with time zone DEFAULT "now"() NOT NULL,
    "CreatedBy" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "UpdatedBy" "uuid" DEFAULT "auth"."uid"() NOT NULL
);


ALTER TABLE "public"."Product" OWNER TO "postgres";


COMMENT ON TABLE "public"."Product" IS 'Product';



COMMENT ON COLUMN "public"."Product"."Id" IS 'Unique identifier of the product';



COMMENT ON COLUMN "public"."Product"."GUID" IS 'External unique identifier';



COMMENT ON COLUMN "public"."Product"."StoreId" IS 'Store identifier';



COMMENT ON COLUMN "public"."Product"."Name" IS 'Name of the product';



COMMENT ON COLUMN "public"."Product"."Description" IS 'Description of the product';



COMMENT ON COLUMN "public"."Product"."Dimensions" IS 'Dimensions of the product';



COMMENT ON COLUMN "public"."Product"."Color" IS 'Color of the product';



COMMENT ON COLUMN "public"."Product"."NumberInStock" IS 'Number of products in stock';



COMMENT ON COLUMN "public"."Product"."Price" IS 'Original price of the product, without any discount';



COMMENT ON COLUMN "public"."Product"."Discount" IS 'Discount applied to the product';



COMMENT ON COLUMN "public"."Product"."IsActive" IS 'Indicates if the Product is still active';



COMMENT ON COLUMN "public"."Product"."CreatedOn" IS 'The date the Product was created';



COMMENT ON COLUMN "public"."Product"."UpdatedOn" IS 'Last time the product was updated';



COMMENT ON COLUMN "public"."Product"."CreatedBy" IS 'Who created the product';



COMMENT ON COLUMN "public"."Product"."UpdatedBy" IS 'Who last updated the product';



CREATE OR REPLACE FUNCTION "public"."CR_GetProductsByStore"("store" "uuid", "search" "text", "status" "text", "limit_input" integer, "offset_input" integer) RETURNS SETOF "public"."Product"
    LANGUAGE "sql"
    AS $$select "Product".*
from "Product" inner join "Store" on "Store"."Id" = "Product"."StoreId"
where "Store"."GUID" = store and 
(search = '' or 
UPPER("Product"."Name") like '%'||UPPER(search)||'%' or 
UPPER("Product"."Description") like '%'||UPPER(search)||'%') and 
((status = '1') or 
 (status = '2' and "Product"."IsActive" = True) or 
 (status = '3' and "Product"."IsActive" = False))
 order by "Product"."Name" asc
limit limit_input offset offset_input;$$;


ALTER FUNCTION "public"."CR_GetProductsByStore"("store" "uuid", "search" "text", "status" "text", "limit_input" integer, "offset_input" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."CR_GetStore"("storeguid" "uuid") RETURNS "record"
    LANGUAGE "sql"
    AS $$select
  public."Store".*
from
  public."Store"
where
  public."Store"."GUID" = StoreGUID$$;


ALTER FUNCTION "public"."CR_GetStore"("storeguid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$begin
  insert into public.profiles (id, first_name, last_name)
  values (new.id, new.raw_user_meta_data ->> 'first_name', new.raw_user_meta_data ->> 'last_name');
  return new;
end;$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."Store" (
    "Id" bigint NOT NULL,
    "GUID" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "Name" "text" NOT NULL,
    "Description" "text",
    "Address" "text",
    "NumberOfProducts" bigint DEFAULT '0'::bigint,
    "CreatedOn" timestamp with time zone DEFAULT "now"() NOT NULL,
    "UpdatedOn" timestamp with time zone DEFAULT "now"() NOT NULL,
    "IsActive" boolean DEFAULT true NOT NULL,
    "CreatedBy" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "UpdatedBy" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "Earnings" numeric DEFAULT '0'::numeric NOT NULL
);


ALTER TABLE "public"."Store" OWNER TO "postgres";


COMMENT ON TABLE "public"."Store" IS 'Store';



COMMENT ON COLUMN "public"."Store"."Id" IS 'Unique identifier of the store';



COMMENT ON COLUMN "public"."Store"."GUID" IS 'External unique identifier';



COMMENT ON COLUMN "public"."Store"."Name" IS 'Name of the store';



COMMENT ON COLUMN "public"."Store"."Description" IS 'Description of the store';



COMMENT ON COLUMN "public"."Store"."Address" IS 'Address of the store';



COMMENT ON COLUMN "public"."Store"."NumberOfProducts" IS 'Number of products in the store';



COMMENT ON COLUMN "public"."Store"."CreatedOn" IS 'The date the store was created';



COMMENT ON COLUMN "public"."Store"."UpdatedOn" IS 'Last time the store was updated';



COMMENT ON COLUMN "public"."Store"."IsActive" IS 'Indicates if the store is still active';



COMMENT ON COLUMN "public"."Store"."CreatedBy" IS 'Who created the store';



COMMENT ON COLUMN "public"."Store"."UpdatedBy" IS 'Who last updated the store';



COMMENT ON COLUMN "public"."Store"."Earnings" IS 'Total earnings from product sales';



CREATE OR REPLACE FUNCTION "public"."tp_store_getlist"() RETURNS SETOF "public"."Store"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY SELECT * FROM "Store";
END;
$$;


ALTER FUNCTION "public"."tp_store_getlist"() OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."Connection" (
    "Id" bigint NOT NULL,
    "GUID" "uuid" NOT NULL,
    "Endpoint" "text",
    "Client" "text",
    "Secret" "text",
    "CreatedOn" timestamp with time zone DEFAULT "now"() NOT NULL,
    "UpdatedOn" timestamp with time zone DEFAULT "now"() NOT NULL,
    "CreatedBy" "uuid" NOT NULL,
    "UpdatedBy" "uuid" NOT NULL,
    "IsActive" boolean DEFAULT true NOT NULL,
    "Description" "text" NOT NULL
);


ALTER TABLE "public"."Connection" OWNER TO "postgres";


COMMENT ON TABLE "public"."Connection" IS 'Connection to other store';



COMMENT ON COLUMN "public"."Connection"."Id" IS 'Unique identifier of the connection';



COMMENT ON COLUMN "public"."Connection"."GUID" IS 'External unique identifier';



COMMENT ON COLUMN "public"."Connection"."Endpoint" IS 'Endpoint of the connection call';



COMMENT ON COLUMN "public"."Connection"."Client" IS 'Client of the connection call';



COMMENT ON COLUMN "public"."Connection"."Secret" IS 'Secret of the connection call';



COMMENT ON COLUMN "public"."Connection"."CreatedOn" IS 'The date the connection was created';



COMMENT ON COLUMN "public"."Connection"."UpdatedOn" IS 'Last time the connection was updated';



COMMENT ON COLUMN "public"."Connection"."CreatedBy" IS 'Who created the connection';



COMMENT ON COLUMN "public"."Connection"."UpdatedBy" IS 'Who last updated the connection';



COMMENT ON COLUMN "public"."Connection"."IsActive" IS 'Indicates if the connection is still active';



COMMENT ON COLUMN "public"."Connection"."Description" IS 'Description of the connection';



CREATE TABLE IF NOT EXISTS "public"."Document" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "name" "text"
);


ALTER TABLE "public"."Document" OWNER TO "postgres";


ALTER TABLE "public"."Document" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."Document_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



ALTER TABLE "public"."Connection" ALTER COLUMN "Id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."External_Stores_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."File" (
    "Id" bigint NOT NULL,
    "ProductId" bigint NOT NULL,
    "FilePath" "text" NOT NULL,
    "FileLocation" "text" NOT NULL,
    "CreatedOn" timestamp with time zone DEFAULT "now"() NOT NULL,
    "UpdatedOn" timestamp with time zone DEFAULT "now"() NOT NULL,
    "CreatedBy" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "UpdatedBy" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "IsActive" boolean DEFAULT true NOT NULL,
    "FileName" "text" NOT NULL
);


ALTER TABLE "public"."File" OWNER TO "postgres";


COMMENT ON TABLE "public"."File" IS 'File';



COMMENT ON COLUMN "public"."File"."Id" IS 'Unique identifier if the file';



COMMENT ON COLUMN "public"."File"."ProductId" IS 'Product identifier';



COMMENT ON COLUMN "public"."File"."FilePath" IS 'Bucket file path';



COMMENT ON COLUMN "public"."File"."FileLocation" IS 'Bucket name';



COMMENT ON COLUMN "public"."File"."CreatedOn" IS 'The date the file was created';



COMMENT ON COLUMN "public"."File"."UpdatedOn" IS 'Last time the file was updated';



COMMENT ON COLUMN "public"."File"."CreatedBy" IS 'Who created the file';



COMMENT ON COLUMN "public"."File"."UpdatedBy" IS 'Who last updated the file';



COMMENT ON COLUMN "public"."File"."IsActive" IS 'Indicates if the file is still active';



COMMENT ON COLUMN "public"."File"."FileName" IS 'Name of the file';



ALTER TABLE "public"."File" ALTER COLUMN "Id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."Images_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



ALTER TABLE "public"."Product" ALTER COLUMN "Id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."Product_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



ALTER TABLE "public"."Store" ALTER COLUMN "Id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."Store_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" NOT NULL,
    "first_name" "text",
    "last_name" "text",
    "storeGUID" "uuid"
);


ALTER TABLE "public"."profiles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."roles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."roles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."userRoles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "userId" "uuid" NOT NULL,
    "roleId" "uuid" NOT NULL
);


ALTER TABLE "public"."userRoles" OWNER TO "postgres";


ALTER TABLE ONLY "public"."Document"
    ADD CONSTRAINT "Document_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."Connection"
    ADD CONSTRAINT "External_Stores_GUID_key" UNIQUE ("GUID");



ALTER TABLE ONLY "public"."Connection"
    ADD CONSTRAINT "External_Stores_ID_key" UNIQUE ("Id");



ALTER TABLE ONLY "public"."Connection"
    ADD CONSTRAINT "External_Stores_pkey" PRIMARY KEY ("Id");



ALTER TABLE ONLY "public"."File"
    ADD CONSTRAINT "Images_ID_key" UNIQUE ("Id");



ALTER TABLE ONLY "public"."File"
    ADD CONSTRAINT "Images_pkey" PRIMARY KEY ("Id");



ALTER TABLE ONLY "public"."Product"
    ADD CONSTRAINT "Product_GUID_key" UNIQUE ("GUID");



ALTER TABLE ONLY "public"."Product"
    ADD CONSTRAINT "Product_ID_key" UNIQUE ("Id");



ALTER TABLE ONLY "public"."Product"
    ADD CONSTRAINT "Product_pkey" PRIMARY KEY ("Id");



ALTER TABLE ONLY "public"."Store"
    ADD CONSTRAINT "Store_GUID_key" UNIQUE ("GUID");



ALTER TABLE ONLY "public"."Store"
    ADD CONSTRAINT "Store_ID_key" UNIQUE ("Id");



ALTER TABLE ONLY "public"."Store"
    ADD CONSTRAINT "Store_pkey" PRIMARY KEY ("Id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."roles"
    ADD CONSTRAINT "roles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."userRoles"
    ADD CONSTRAINT "userRoles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."Connection"
    ADD CONSTRAINT "Connection_CreatedBy_fkey" FOREIGN KEY ("CreatedBy") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."Connection"
    ADD CONSTRAINT "Connection_UpdatedBy_fkey" FOREIGN KEY ("UpdatedBy") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."File"
    ADD CONSTRAINT "File_CreatedBy_fkey" FOREIGN KEY ("CreatedBy") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."File"
    ADD CONSTRAINT "File_UpdatedBy_fkey" FOREIGN KEY ("UpdatedBy") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."File"
    ADD CONSTRAINT "Images_ProductId_fkey" FOREIGN KEY ("ProductId") REFERENCES "public"."Product"("Id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."Product"
    ADD CONSTRAINT "Product_CreatedBy_fkey" FOREIGN KEY ("CreatedBy") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."Product"
    ADD CONSTRAINT "Product_StoreId_fkey" FOREIGN KEY ("StoreId") REFERENCES "public"."Store"("Id");



ALTER TABLE ONLY "public"."Product"
    ADD CONSTRAINT "Product_UpdatedBy_fkey" FOREIGN KEY ("UpdatedBy") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."Store"
    ADD CONSTRAINT "Store_CreatedBy_fkey" FOREIGN KEY ("CreatedBy") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."Store"
    ADD CONSTRAINT "Store_UpdatedBy_fkey" FOREIGN KEY ("UpdatedBy") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_storeGUID_fkey" FOREIGN KEY ("storeGUID") REFERENCES "public"."Store"("GUID");



ALTER TABLE ONLY "public"."userRoles"
    ADD CONSTRAINT "userRoles_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES "public"."roles"("id");



ALTER TABLE ONLY "public"."userRoles"
    ADD CONSTRAINT "userRoles_userId_fkey" FOREIGN KEY ("userId") REFERENCES "auth"."users"("id");



CREATE POLICY "Authenticated users can insert records" ON "public"."Connection" FOR INSERT TO "authenticated" WITH CHECK (true);



CREATE POLICY "Authenticated users can insert records" ON "public"."File" FOR INSERT TO "authenticated" WITH CHECK (true);



CREATE POLICY "Authenticated users can insert records" ON "public"."Product" FOR INSERT TO "authenticated" WITH CHECK (true);



CREATE POLICY "Authenticated users can insert records" ON "public"."Store" FOR INSERT TO "authenticated" WITH CHECK (true);



CREATE POLICY "Authenticated users can update records" ON "public"."Connection" FOR UPDATE TO "authenticated" USING (true) WITH CHECK (true);



CREATE POLICY "Authenticated users can update records" ON "public"."File" FOR UPDATE TO "authenticated" USING (true) WITH CHECK (true);



CREATE POLICY "Authenticated users can update records" ON "public"."Product" FOR UPDATE TO "authenticated" USING (true) WITH CHECK (true);



CREATE POLICY "Authenticated users can update records" ON "public"."Store" FOR UPDATE TO "authenticated" USING (true) WITH CHECK (true);



ALTER TABLE "public"."Connection" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."Document" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "Enable delete for authenticated users only" ON "public"."Product" FOR DELETE TO "authenticated" USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."Connection" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."File" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."Product" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."Store" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."profiles" FOR SELECT USING (true);



ALTER TABLE "public"."File" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."Product" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."Store" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."roles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."userRoles" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";





GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";















































































































































































































































































































GRANT ALL ON FUNCTION "public"."CR_CheckUserRole"("userid" "uuid", "roleid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."CR_CheckUserRole"("userid" "uuid", "roleid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."CR_CheckUserRole"("userid" "uuid", "roleid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."CR_GetMyStore"() TO "anon";
GRANT ALL ON FUNCTION "public"."CR_GetMyStore"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."CR_GetMyStore"() TO "service_role";



GRANT ALL ON FUNCTION "public"."CR_GetProduct"("productguid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."CR_GetProduct"("productguid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."CR_GetProduct"("productguid" "uuid") TO "service_role";



GRANT ALL ON TABLE "public"."Product" TO "anon";
GRANT ALL ON TABLE "public"."Product" TO "authenticated";
GRANT ALL ON TABLE "public"."Product" TO "service_role";



GRANT ALL ON FUNCTION "public"."CR_GetProductsByStore"("store" "uuid", "search" "text", "status" "text", "limit_input" integer, "offset_input" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."CR_GetProductsByStore"("store" "uuid", "search" "text", "status" "text", "limit_input" integer, "offset_input" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."CR_GetProductsByStore"("store" "uuid", "search" "text", "status" "text", "limit_input" integer, "offset_input" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."CR_GetStore"("storeguid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."CR_GetStore"("storeguid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."CR_GetStore"("storeguid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



GRANT ALL ON TABLE "public"."Store" TO "anon";
GRANT ALL ON TABLE "public"."Store" TO "authenticated";
GRANT ALL ON TABLE "public"."Store" TO "service_role";



GRANT ALL ON FUNCTION "public"."tp_store_getlist"() TO "anon";
GRANT ALL ON FUNCTION "public"."tp_store_getlist"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tp_store_getlist"() TO "service_role";





















GRANT ALL ON TABLE "public"."Connection" TO "anon";
GRANT ALL ON TABLE "public"."Connection" TO "authenticated";
GRANT ALL ON TABLE "public"."Connection" TO "service_role";



GRANT ALL ON TABLE "public"."Document" TO "anon";
GRANT ALL ON TABLE "public"."Document" TO "authenticated";
GRANT ALL ON TABLE "public"."Document" TO "service_role";



GRANT ALL ON SEQUENCE "public"."Document_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."Document_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."Document_id_seq" TO "service_role";



GRANT ALL ON SEQUENCE "public"."External_Stores_ID_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."External_Stores_ID_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."External_Stores_ID_seq" TO "service_role";



GRANT ALL ON TABLE "public"."File" TO "anon";
GRANT ALL ON TABLE "public"."File" TO "authenticated";
GRANT ALL ON TABLE "public"."File" TO "service_role";



GRANT ALL ON SEQUENCE "public"."Images_ID_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."Images_ID_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."Images_ID_seq" TO "service_role";



GRANT ALL ON SEQUENCE "public"."Product_ID_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."Product_ID_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."Product_ID_seq" TO "service_role";



GRANT ALL ON SEQUENCE "public"."Store_ID_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."Store_ID_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."Store_ID_seq" TO "service_role";



GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";



GRANT ALL ON TABLE "public"."roles" TO "anon";
GRANT ALL ON TABLE "public"."roles" TO "authenticated";
GRANT ALL ON TABLE "public"."roles" TO "service_role";



GRANT ALL ON TABLE "public"."userRoles" TO "anon";
GRANT ALL ON TABLE "public"."userRoles" TO "authenticated";
GRANT ALL ON TABLE "public"."userRoles" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";






























RESET ALL;
