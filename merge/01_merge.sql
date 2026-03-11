--Aprendendo Merge
--Parecido com o o upsert (insert on conflict)
--Util para sincronização de tabelas (pode aplicar as tres operacoes em uma unica execução INSERT, UPDATE, DELETE)

/*Destino dos dados*/
merge
into
	learn.funcionarios as t
/*Fonte dos dados*/
		using(
select * from stage.funcionarios_stage 
) as s
on
	t.dta_referencia = s.dta_referencia 
	and t.cpf = s.cpf
	and t.nroempresa = s.nroempresa
/*Caso exista na fonte e no destino então os dados da fonte serão atualizados com base na fonte*/
	when matched then	
update
set
	nome = s.nome, 
	cpf = s.cpf, 
	nroempresa = s.nroempresa, 
	empresa = s.empresa, 
	mes = s.mes, 
	ano = s.ano, 
	dta_referencia = s.dta_referencia, 
	dta_atualizacao = now()
	when not matched then
insert
	(nome,
	cpf,
	nroempresa,
	empresa,
	mes,
	ano,
	dta_referencia,
	dta_atualizacao)
values(
	s.nome, s.cpf, s.nroempresa, s.empresa, 
	s.mes, s.ano, s.dta_referencia, now())
when not matched by source then
    delete
;
	
	
/*Teste 02*/

/*Aqui havera um comportamento inesperado onde é possivel perder dados
 * Por mais que foi dito para filtrar a fonte e o destino, ele ira excluir os dados
 * não encontrados na fonte que existem no destino
 * 
 * Para evitar isso deve se aplicar uma subquery ou CTE antes para ser utilizado como filtro
 * ou deixar explicita a condição para quando não atendida, o delete possa ocorrer, caso contrario
 * usar um soft delete
 * exemplo no teste 3*/

merge
into
	learn.funcionarios as t
/*Fonte dos dados*/
		using(
select * from stage.funcionarios_stage where dta_referencia = '2026-01-01'
) as s
on
	t.dta_referencia = s.dta_referencia 
	and t.cpf = s.cpf
	and t.nroempresa = s.nroempresa
	and t.dta_referencia = '2026-01-01'
when matched then 
	update set
	nome = s.nome,
	empresa = s.empresa,
	mes = s.mes,
	ano = s.ano,
	dta_atualizacao = now()
/*Caso não existe no destino então insere os dados*/
when not matched by target then
	insert(nome, cpf, nroempresa, empresa, mes, ano, dta_referencia, dta_atualizacao)
	values(s.nome, s.cpf, s.nroempresa, s.empresa, s.mes, s.ano, s.dta_referencia, now())
	/*Deleta caso não exista na fonte*/
	when not matched by source THEN
	delete;

/*Teste 03 - Diminuindo o escopo do delete 
 * Aqui nesse caso na condição de delete foi passando um filtro pra que ele possa atuar
 * sem deletar os demais dados da tabela*/
merge
into
	learn.funcionarios as t
/*Fonte dos dados*/
		using(
select * from stage.funcionarios_stage where dta_referencia = '2026-01-01'
) as s
on
	t.dta_referencia = s.dta_referencia 
	and t.cpf = s.cpf
	and t.nroempresa = s.nroempresa
	and t.dta_referencia = '2026-01-01'
when matched then 
	update set
	nome = s.nome,
	empresa = s.empresa,
	mes = s.mes,
	ano = s.ano,
	dta_atualizacao = now()
/*Caso não existe no destino então insere os dados*/
when not matched by target  then 
	insert(nome, cpf, nroempresa, empresa, mes, ano, dta_referencia, dta_atualizacao)
	values(s.nome, s.cpf, s.nroempresa, s.empresa, s.mes, s.ano, s.dta_referencia, now())
	/*Deleta caso não exista na fonte*/
	when not matched by source and t.dta_referencia = '2026-01-01' THEN
	delete;