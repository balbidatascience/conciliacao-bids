use IR

select	month(data_compra) as mes,
		--plataforma_utilizada,  
		sum(valor_compra_original_total) as TotalBruto,
		sum(valor_ingressos_ativos_total) as TotalAtivo 
from dsVendaAtivaLegado
where convert(date, data_compra) = '06/01/2017'
group by month(data_compra)--, plataforma_utilizada
order by mes--, plataforma_utilizada

select top 1000 * from dsVendaAtivaLegado


select distinct plataforma_utilizada from dsVendaAtivaLegado

drop table #tmp

select *, '0' as IsAssociado
into #tmp
from dsVendaAtivaLegado a
where convert(date, data_compra) between '06/01/2017' and '6/30/2017'

-- Total 5.714 --> 3.622 (1/6/2017)
-- 157.926 (162723) --> 45.948 (6/2017)
update #tmp
set IsAssociado = '1'
from #tmp a
inner join dimTransacaoIR b on a.numero_venda_ir = b.Localizador

update #tmp
set IsAssociado = '1'
from #tmp a
inner join dimTransacaoIR b on a.codigo_gateway = b.IDERP
where IsAssociado = '0'

update #tmp
set IsAssociado = '1'
from #tmp a
inner join dimTransacaoIR b on a.numero_autorizacao_adquirente = b.NroAutorizacao
								and a.nsu_host = b.NSU
								and convert(date, a.data_compra) = convert(date, b.DtTransacao) -- todas as datas desta amostragem encontram-se em branco.
								and a.valor_compra_original_total = b.ValorPagamento
where IsAssociado = '0'

157.926 -- somente 3% não associado.  
select count(*) from #tmp where IsAssociado = 0

select * from #tmp where IsAssociado = 0


select b.*
from #tmp a
inner join dimTransacaoIR b on --a.numero_venda_ir <> b.Localizador
							a.codigo_gateway = b.IDERP
where numero_venda_ir in (
'5320649657',
'9520788939',
'9020779917',
'9620754566'
)
order by a.numero_venda_ir

select a.numero_venda_ir, count(b.IdTransacaoIR)
from #tmp a
inner join dimTransacaoIR b on --a.numero_venda_ir <> b.Localizador
							a.codigo_gateway = b.IDERP
group by a.numero_venda_ir
having count(b.IdTransacaoIR) > 1

select top 100 * from dimTransacaoIR where IDERP is null
select * from dimTransacaoIR where nsu like '%272337' and NroAutorizacao like '%13'

select * from #tmp where codigo_gateway= '22a595d7-0928-4393-a180-1450122d183b'

000013
170527
272337

select top 100 a.*, b.*
from dsVendaAtivaLegado a
left join dimTransacaoIR b on a.numero_venda_ir = b.Localizador
where convert(date, data_compra) = '06/01/2017'
order by a.data_compra


select * from dsVendaAtivaLegado
where numero_venda_ir in (
'9620363117',
'2320297128',
'4020359302',
'9720343504',
'9620274113',
'6620284912',
'8520285636',
'2820424100',
'6220300936',
'2920392817',
'6920313489',
'9920316196',
'1320330946',
'8120371992',
'7220275222')


-- 677.782
select count(distinct Localizador) from dimTransacaoIR where Localizador is not null

select Localizador, count(IdTransacaoIR) from dimTransacaoIR where Localizador is not null group by Localizador having count(IdTransacaoIR) > 1

select * from dimTransacaoIR where Localizador in (3919945204, 5819795963, 6020290628) order by Localizador

select * from fatTransacaoIR where IdTransacaoIR in (907761, 925799)

-- 660.956
