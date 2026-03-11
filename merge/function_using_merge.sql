
/*Funcao de sincronismo da tabela de vendas dos representantes*/

create or replace function fn_sinc_vendas_representante(vdata_1 date, vdata_2 date)
returns void
language plpgsql
as
$$
begin
	merge into learn.vendas_representantes as t
	using (
	select * 
	from learn.vendas_representantes_stage where dtavda between vdata_1 and vdata_2) as s
	on 
	t.dtavda = s.dtavda
	and t.id_empresa = s.id_empresa
	and t.id_vendedor = s.id_vendedor
	and t.dtavda between vdata_1 and vdata_2
	when matched then
		update set
		nrodoctos = s.nrodoctos,
		vlr_venda = s.vlr_venda,
		dta_atualizacao = now()
	when not matched by target then
		insert (dtavda, id_empresa, id_vendedor, nrodoctos, vlr_venda, dta_atualizacao)
		values (s.dtavda, s.id_empresa, s.id_vendedor, s.nrodoctos, s.vlr_venda, now())
	when not matched by source and dtavda between vdata_1 and vdata_2 then 
	delete;
end;
$$;

/*Chamada da funcao*/

SELECT learn.fn_sinc_vendas_representante(:vdata_1, :vdata_2);