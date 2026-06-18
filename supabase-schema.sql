-- ============================================================
-- DISSENTI4L AGENCY OS — Estrutura do banco (Supabase / PostgreSQL)
-- Cole TODO este conteúdo no SQL Editor do Supabase e clique em "Run".
-- ============================================================

-- ----------- CLIENTES -----------
create table if not exists clientes (
  id          bigint generated always as identity primary key,
  nome        text not null,
  pacote      text default 'Starter',
  valor       numeric default 0,
  resp        text,
  venc        date,
  wpp         text,
  email       text,
  cnpj        text,
  leads       int default 0,
  ad_spend    numeric default 0,
  cpl         numeric default 0,
  roas        numeric default 0,
  status      text default 'Ativo',
  arquivado   boolean default false,
  notas       text,
  criado_em   timestamptz default now()
);

-- ----------- METAS (linha única) -----------
create table if not exists metas (
  id        int primary key default 1,
  mrr       numeric default 50000,
  clientes  int default 10,
  leads     int default 1000,
  cpl       numeric default 40,
  ads       numeric default 25000,
  reunioes  int default 20,
  constraint metas_single check (id = 1)
);
insert into metas (id) values (1) on conflict (id) do nothing;

-- ----------- DADOS REAIS DO MÊS (linha única) -----------
create table if not exists real_mes (
  id        int primary key default 1,
  mrr       numeric default 0,
  clientes  int default 0,
  leads     int default 0,
  ads       numeric default 0,
  new_val   numeric default 0,
  churn_val numeric default 0,
  new_n     int default 0,
  churn_n   int default 0,
  hoje      numeric default 0,
  reunioes  int default 0,
  constraint real_single check (id = 1)
);
insert into real_mes (id) values (1) on conflict (id) do nothing;

-- ----------- TAREFAS -----------
create table if not exists tarefas (
  id        bigint generated always as identity primary key,
  titulo    text not null,
  cliente   text,
  resp      text,
  prazo     text,
  coluna    text default 'solicitacao',
  criado_em timestamptz default now()
);

-- ----------- ASSETS -----------
create table if not exists assets (
  id        bigint generated always as identity primary key,
  nome      text,
  cliente   text,
  tipo      text,
  status    text,
  link      text,
  data      text,
  criado_em timestamptz default now()
);

-- ----------- FINANCEIRO -----------
create table if not exists financeiro (
  id        bigint generated always as identity primary key,
  data      text,
  descricao text,
  cliente   text,
  tipo      text,          -- 'Entrada' ou 'Saída'
  valor     numeric default 0,
  criado_em timestamptz default now()
);

-- ----------- REUNIÕES -----------
create table if not exists reunioes (
  id        bigint generated always as identity primary key,
  cliente   text,
  data      text,
  tipo      text,
  status    text default 'A confirmar',
  criado_em timestamptz default now()
);

-- ----------- SOLICITAÇÕES -----------
create table if not exists solicitacoes (
  id          bigint generated always as identity primary key,
  cliente     text,
  req         text,
  data        text,
  prioridade  text default 'Normal',
  criado_em   timestamptz default now()
);

-- ----------- CAMPANHAS -----------
create table if not exists campanhas (
  id        bigint generated always as identity primary key,
  nome      text not null,
  origem    text default 'cliente',   -- 'agencia' ou 'cliente'
  cliente   text,
  verba     numeric default 0,
  gasto     numeric default 0,
  leads     int default 0,
  cpl       numeric default 0,
  roas      numeric default 0,
  status    text default 'Ativa',
  criado_em timestamptz default now()
);

-- ============================================================
-- SEGURANÇA (RLS) — só usuários logados acessam.
-- Protege seus dados financeiros de quem não estiver autenticado.
-- ============================================================
alter table clientes      enable row level security;
alter table metas         enable row level security;
alter table real_mes      enable row level security;
alter table tarefas       enable row level security;
alter table assets        enable row level security;
alter table financeiro    enable row level security;
alter table reunioes      enable row level security;
alter table solicitacoes  enable row level security;
alter table campanhas     enable row level security;

-- Política: qualquer usuário AUTENTICADO pode ler/gravar tudo.
do $$
declare t text;
begin
  foreach t in array array['clientes','metas','real_mes','tarefas','assets','financeiro','reunioes','solicitacoes','campanhas']
  loop
    execute format('drop policy if exists "auth_all" on %I;', t);
    execute format('create policy "auth_all" on %I for all to authenticated using (true) with check (true);', t);
  end loop;
end $$;

-- ============================================================
-- DADOS DE EXEMPLO (pode apagar depois)
-- ============================================================
insert into clientes (nome,pacote,valor,resp,venc,wpp,email,cnpj,leads,ad_spend,cpl,roas,status,arquivado,notas) values
 ('Clínica Monte Sinai','Premium',8500,'BB','2026-12-01','(11) 99999-1111','contato@montesinai.com','12.345.678/0001-90',572,18420,32.18,4.2,'Ativo',false,'Cliente desde jan/2026. Foco em captação para endometriose e menopausa.'),
 ('Instituto ABC','Growth',5000,'BB','2026-10-15','(11) 99999-2222','marketing@institutoabc.com','98.765.432/0001-10',210,8000,38.10,3.1,'Ativo',false,'Nova oferta combo em desenvolvimento.'),
 ('Consultoria Forma','Starter',3000,'LA','2026-09-30','(11) 99999-3333','ola@consultoriaforma.com','45.678.901/0001-23',98,3500,35.71,2.8,'Em risco',false,'Atenção: ROAS abaixo da meta. Renovação em risco.');

insert into campanhas (nome,origem,cliente,verba,gasto,leads,cpl,roas,status) values
 ('Dissenti4l — Captação de clientes','agencia',null,6000,4100,54,75.92,6.0,'Ativa'),
 ('Dissenti4l — Remarketing site','agencia',null,2000,900,18,50.00,8.0,'Ativa'),
 ('Captação - Instagram','cliente','Clínica Monte Sinai',15000,10200,320,31.87,4.1,'Ativa'),
 ('Leads Médicos','cliente','Instituto ABC',8000,5500,180,30.55,3.0,'Ativa');
