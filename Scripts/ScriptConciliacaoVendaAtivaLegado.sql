

--===============================================================================
-- analisando valores por lote
-- drop table #tmp
select  c.LoteUnico, 
		--b.DATA,
		sum(ValorVenda) as ValorVenda, 
		sum(ValorTransacionadoAdquirente) as ValorTransacionadoAdquirente, 
		sum(ValorCanceladoVenda) as ValorCanceladoVenda, 
		sum(ValorCanceladoLiquido) as ValorCanceladoLiquido, 
		sum(ValorCBK) as ValorCBK, 
		sum(ValorCBKLiquido) as ValorCBKLiquido, 
		sum(ComissaoAdquirente) as ValorComissao, 
		sum(ValorAntecipacaoCedida) as ValorAntecipacaoCedida, 
		sum(ValorAntecipacao) as ValorAntecipacao, 
		sum(TaxaAntecipacao) as ValorTaxaAntecipacao, 
		sum(ValorOutrosAjustes) as ValorOutrosAjustes, 
		sum(ValorPrevistoConciliador) as ValorPrevisto, 
		sum(ValorPago) as ValorPago
		into #tmp
from fatConciliacaoLoteVenda a
inner join dimTempo b on a.IdDataVenda = b.IdTempo
inner join dimLoteVenda c on a.IdLoteVenda = c.IdLoteVenda
where b.DATA <= '10/20/2017'
group by c.LoteUnico--, b.DATA
--order by b.DATA

select * from #tmp where ValorVenda > 0 
--===============================================================================
 


 --======================================
 -- RASCUNHO

 --truncate table fatConciliacaoLoteVenda

select * from dsVendaAtivaBileto where numero_autorizacao_adquirente like '%671532%'
select * from dsVendaAtivaLegado where numero_autorizacao_adquirente like '%671532%'

select * from dsVendaAtivaBileto where numero_autorizacao_adquirente like '%651521%'
select * from dsVendaAtivaLegado where numero_autorizacao_adquirente like '%651521%'

select b.IdTransacaoAdquirente, a.* from dimTransacaoIR a
left join fatTransacaoIR b on a.IdTransacaoIR = b.IdTransacaoAdquirente
where Localizador like '%6520352082%'

select * from dimLoteVenda where IdLoteVenda = 107299
select * from dimLoteVenda where LoteUnico = '170035100204846'

-- 208 -- Apenas 48 foram Identificadas
select * from fatConciliacaoVenda where IdTransacaoAdquirente in (
select distinct IdTransacaoAdquirente
from dimTransacaoAdquirente 
where LoteUnico = '170035100204846') 


select sum(ValorVenda), sum(ValorCanceladoVenda), sum(ValorTransacionadoAdquirente), sum(ValorCanceladoAdquirente) from fatConciliacaoVenda where IdLoteVenda in (
101193,
107299,
138890)

select sum(ValorVenda) as ValorVenda, 
		sum(ValorCanceladoVenda) as ValorCanceladoVenda, 
		sum(ValorTransacionadoAdquirente) as ValorTransacionadoAdquirente, 
		sum(ValorCanceladoLiquido) as ValorCanceladoLiquido, 
		sum(ValorPrevistoConciliador) as ValorPrevistoConciliador, 
		sum(ValorPago) as ValorPago 
from fatConciliacaoLoteVenda where IdLoteVenda in (
101193,
107299,
138890)


select a.* 
from fatConciliacaoVenda a
left join dimTempo b on a.IdDataVenda = b.IdTempo
where convert(date, b.data) = '6/1/2017'

select a.* 
from fatConciliacaoLoteVenda a
inner join dimTempo b on a.IdDataVenda = b.IdTempo
where convert(date, b.DATA) = '6/1/2017'






