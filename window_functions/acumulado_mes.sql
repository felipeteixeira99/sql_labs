SELECT 
dtavda, 
id_empresa, 
id_vendedor, 
nrodoctos, 
vlr_venda, 
sum(vlr_venda) over (order by
/*Pega o intervalos das linhas anteriores para realizar a soma*/
dtavda rows between unbounded preceding and current row) as acumulado_vendas,	
now() as dta_atualizacao
FROM learn.vendas_representantes
where dtavda between '2026-01-01' and '2026-01-15'
order by id_empresa, dtavda, id_vendedor;