/*Window Functions*/

with cte as (
select
	dta_referencia,
	seqpessoa,
	fornecedor,
	nroempresa,
	de.nomereduzido,
	/*Valor Operacao do fornecedor por empresa no Mês*/
	sum(vlroperacao) over (partition by dta_referencia,
	seqpessoa,
	fornecedor,
	nroempresa
	order by nroempresa) as valor_fornecedor_empresa_mes,
	/*Valor Operacao total do fornecedor no mês*/
	sum(vlroperacao) over (
partition by dta_referencia,
	seqpessoa,
	fornecedor) valor_fornecedor_mes,
	/*Valor Operacao do fornecedor por ano*/
	sum(vlroperacao) over (partition by extract('year' from dta_referencia),
	seqpessoa) as valor_fornecedor_ano
	from
	vendas.f_receita_fornecedor
inner join bi.d_empresa de
		using (nroempresa)
where
	extract('year' from dta_referencia) = 2025)
select 
dta_referencia, 
seqpessoa, 
fornecedor, 
nroempresa, 
nomereduzido, 
valor_fornecedor_empresa_mes,
rank() over (partition by dta_referencia, nroempresa order by  valor_fornecedor_empresa_mes desc) as ranking_fornecedor_empresa_mes,
valor_fornecedor_mes, 
rank() over (partition by dta_referencia order by valor_fornecedor_mes desc) as ranking_fornecedor_mes,
valor_fornecedor_ano,
rank() over (partition by extract('year' from dta_referencia) order by valor_fornecedor_ano desc)
from cte;