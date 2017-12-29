
--=========================================================================================
-- VALIDAÇÃO DE VENDA SEM TRANSAÇÃO
-- De: 1.902.598
-- Não conciliado (sem IdTransacaoAdquirente): 216.654 (11,38%)
--	Sendo: 33.171 canceladas no mesmo dia e 50.973 canceladas
--  Ou seja, das vendas ativas: 1.797.764:
--				Não conciliado: 165.681 (9%) sendo 84.038 (50%) do gateway MundiPagg
--=========================================================================================
select count(*)
from fatConciliacaoVenda a
inner join dimVenda b on a.IdVenda = b.IdVenda
where b.IsCancelada = 0
and a.IdTransacaoAdquirente = -1
and b.gateway = 'Mundipagg'
--and b.IsCanceladaMesmoDia = 1
--and b.IsCancelada = 1


select * from dimvenda where numero_venda_ir = '7519361775'
select * from fatConciliacaoVenda where IdVenda = 104890

select * from fatConciliacaoVenda where ValorVenda <= 0

select a.* 
from dimVenda a
inner join fatConciliacaoVenda b on a.IdVenda = b.IdVenda 
where gateway = 'Mundipagg' and data_compra >= '09/01/2017'
and b.IdTransacaoAdquirente = -1

--=========================================================================================
-- VALIDAÇÃO DE TRANSAÇÃO SEM VENDA
-- De: 1.693.363
-- Não conciliado (sem IdVenda): 183.125 (9,16%)
--	Sendo: 1.648.727 ativa (91,6% conciliado das ativas)
--  Ou seja, das vendas ativas: 
--				Não conciliado: (9%) Sendo 56% na Cielo e 42% na Rede
--=========================================================================================
select count(a.IdTransacaoAdquirente), a.Adquirente
from dimTransacaoAdquirente a
left join fatConciliacaoVenda b on a.IdTransacaoAdquirente = b.IdTransacaoAdquirente
where a.Data <= '10/15/2017' 
--and a.IsCanceladoPagamento = 0
and a.IdTransacaoAdquirente <> -1
and b.IdTransacaoAdquirente is null
group by a.Adquirente
order by 1 desc


--=========================================================================================
-- VALIDAÇÃO DE VENDA SEM INFORMAÇÃO DE PAGAMENTO 
-- De: 1.902.598
-- Não conciliado (sem IdLoteVenda): 216.654 (11,38%) As mesmas sem a transação. Ou seja, identificou a transação, sabe o pagamento. 
--		Total de: 1.685.944	- R$ 352.078.425,04 Conciliado Venda
--		Não conciliado: 165.681 (9%) sendo 84.038 (50%) do gateway MundiPagg

-- Dos Lotes 
--=========================================================================================

-- De: 112.518
select count(distinct IdLoteVenda)--, sum(ValorVenda), sum(ValorBrutoAdquirente), sum(ValorPrevistoConciliador), sum(ValorPago)
from fatConciliacaoLoteVenda 
where IdLoteVenda <> -1

-- Sendo 17.401 lotes com previsto <= 0
-- 2832 com previsto = 0
-- 
select a.IdLoteVenda, b.LoteUnico, sum(ValorVenda) as Venda, sum(ValorBrutoAdquirente) as Adquirente, sum(ValorPrevistoConciliador) as Previsto, sum(ValorPago) as Pago
from fatConciliacaoLoteVenda a
inner join dimLoteVenda b on a.IdLoteVenda = b.IdLoteVenda
where a.IdLoteVenda <> -1
group by a.IdLoteVenda, b.LoteUnico
having sum(ValorPrevistoConciliador) = 0
and sum(ValorBrutoAdquirente) = 0
order by b.LoteUnico

select * from dimLoteVenda where IdLoteVenda = 14537

select count(a.IdVenda), sum(a.ValorVenda)
from fatConciliacaoVenda a
inner join dimVenda b on a.IdVenda = b.IdVenda
where IdLoteVenda <> -1


select count(*) from dimLoteVenda 



select sum(valor_compra_original_total) from dimVenda

fatConciliacaoLoteVenda 


426972303,03
352078425,04


--=========================================================================================
-- VALIDAÇÃO DE VENDA CANCELADA 
-- De: 1.902.598
-- Existem 5.034 casos da transação está cancelada, mas a venda não.
-- E 64.832 casos onde a venda está cancelada, mas a transação não. 
-- Dos Lotes 
--=========================================================================================

select * from fatConciliacaoVenda where ValorCanceladoAdquirente = 0 and ValorCanceladoVenda > 0
select * from dimVenda where IdVenda = 1850
select * from dsVendaAtivaLegadoHist where numero_venda_ir = '1020711397'
select * from dsVendaCanceladaLegadoHist where numero_venda_ir = '1020711397' 

select * from dimVenda 


--=========================================================================================
-- CBK DETALHE
-- De: 18091 CBKs
-- 17328 (96%) Conciliados (estão IdTransacao na fatConciliacaoVenda)
--=========================================================================================

select count(*) 
from dimTransacaoAdquirente a
inner join fatConciliacaoVenda b on a.IdTransacaoAdquirente = b.IdTransacaoAdquirente
where a.IsChargeback = 1

select plataforma_utilizada, count(*), is_bileto from dimVenda  group by plataforma_utilizada, is_bileto

-- Seta a Venda da Transação
update fatTransacaoAdquirente 
set IdVenda = b.IdVenda 
from fatTransacaoAdquirente a
inner join fatConciliacaoVenda b on a.IdTransacaoAdquirente = b.IdTransacaoAdquirente
where a.IdTransacaoAdquirente <> -1


drop table #tmp

-- Legado Ativo
select is_bileto, 
		numero_venda_ir,  
		plataforma_utilizada, 
		nome_evento as NomeEvento, 
		id_evento, 
		min(data_evento) as DataEvento, 
		nome_local, 
		tipo_evento 
into #tmp
from dsVendaAtivaLegadoHist
group by is_bileto, 
		numero_venda_ir,  
		plataforma_utilizada, 
		nome_evento, 
		id_evento, 
		nome_local, 
		tipo_evento 
-- Legado cancelado
insert into #tmp
select is_bileto, 
		numero_venda_ir,  
		plataforma_utilizada, 
		nome_evento as NomeEvento, 
		id_evento, 
		min(data_evento) as DataEvento, 
		nome_local, 
		tipo_evento 
from dsVendaCanceladaLegadoHist
group by is_bileto, 
		numero_venda_ir,  
		plataforma_utilizada, 
		nome_evento, 
		id_evento, 
		nome_local, 
		tipo_evento 
-- Bileto Ativo
insert into #tmp
select is_bileto, 
		numero_venda_ir,  
		plataforma_utilizada, 
		nome_evento as NomeEvento, 
		id_evento, 
		min(data_evento) as DataEvento, 
		nome_local, 
		tipo_evento 
from dsVendaAtivaBiletoHist
group by is_bileto, 
		numero_venda_ir,  
		plataforma_utilizada, 
		nome_evento, 
		id_evento, 
		nome_local, 
		tipo_evento 
-- Bileto cancelado
insert into #tmp
select is_bileto, 
		numero_venda_ir,  
		plataforma_utilizada, 
		nome_evento as NomeEvento, 
		id_evento, 
		min(data_evento) as DataEvento, 
		nome_local, 
		tipo_evento 
from dsVendaCanceladaBiletoHist
group by is_bileto, 
		numero_venda_ir,  
		plataforma_utilizada, 
		nome_evento, 
		id_evento, 
		nome_local, 
		tipo_evento 


update dimVenda 
set NomeEvento = b.NomeEvento, 
DataEvento = b.DataEvento, 
NomeLocal = b.nome_local, 
TipoEvento = b.tipo_evento, 
plataforma_utilizada = b.plataforma_utilizada
from dimVenda a
inner join #tmp b on a.is_bileto = b.is_bileto
					and a.numero_venda_ir = b.numero_venda_ir

drop table #tmp

select * 
from dimVenda 



select * from #tmp where numero_venda_ir = '5320549082'
select * from dimVenda where numero_venda_ir = '5320549082'

select numero_venda_ir, count(*) from #tmp group by numero_venda_ir having count(*) > 1

select * from #tmp where numero_venda_ir in (
'7820386651',
'5320549082',
'8821007783')
