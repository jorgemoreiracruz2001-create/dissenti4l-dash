-- ============================================================
-- NOVA TABELA: etapas do processo de Onboarding (editável)
-- Cole no SQL Editor do Supabase e clique em "Run".
-- ============================================================
create table if not exists onboarding_etapas (
  id        bigint generated always as identity primary key,
  texto     text not null,
  feito     boolean default false,
  ordem     int default 0,
  criado_em timestamptz default now()
);

alter table onboarding_etapas enable row level security;
drop policy if exists "auth_all" on onboarding_etapas;
create policy "auth_all" on onboarding_etapas for all to authenticated using (true) with check (true);

-- Etapas iniciais (pode editar/apagar tudo depois pela própria plataforma)
insert into onboarding_etapas (texto, ordem) values
 ('Briefing preenchido', 1),
 ('Acesso ao BM concedido', 2),
 ('Pixel instalado e testado', 3),
 ('Pixel Events confirmados', 4),
 ('Número WhatsApp configurado', 5),
 ('CRM conectado', 6),
 ('Reunião de kick-off realizada', 7),
 ('Plano de mídia aprovado', 8),
 ('Primeira campanha criada', 9),
 ('Relatório de acesso enviado ao cliente', 10);
