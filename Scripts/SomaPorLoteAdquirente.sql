use IR

/****************************************************************************************************************************************************************
* ANALISE DE QUANTO VENDI VS QUANDO ESTOU RECEBENDO
****************************************************************************************************************************************************************/
--drop table #tmpCaixa
--drop table #tmpVenda

117166948135752

select * from #tmpCaixa where LoteUnico = '171661210131819'
select * from dsFluxoCaixa where LoteUnico = '171661210131819' order by DataVencimento
select * from #tmpVenda where LoteUnico = '171661210131819'
select * from dimCancelamento where LoteUnico = '171661210131819'
select * from dimTransacaoAdquirente a inner join fatTransacaoAdquirente b on a.IdTransacaoAdquirente = b.IdTransacaoAdquirente where LoteUnico = '171661210131819'

select * from dsMovimentoFinanceiro where [Lote Único] = '171661210131819'


select a.IdLoteVenda, a.Lote, a.LoteUnico, a.Adquirente, c.DATA, sum(b.ValorBruto) as ValorBrutoCaixa, 
		sum(b.ValorComissao)as ValorComissaoCaixa, 
		sum(b.ValorBruto-b.ValorComissao) as ValorLiquidoCaixa, 
		sum(b.ValorAntecipacao) as AntecipacaoCaixa, 
		sum(b.TaxaAntecipacao) as TaxaAntecipacaoCaixa, 
		sum(b.ValorOutrosAjustes) as OutrosAjustesCaixa,
		sum(b.ValorCancelamentoLiquido) as CancelamentoLiquidoCaixa, 
		sum(b.ValorCBKLiquido) as ValorCBKLiquidoCaixa, 
		sum(b.ValorPrevisto) as ValorPrevistoCaixa, 
		sum(b.ValorPago) as ValorPagoCaixa, 
		sum(b.Saldo) as SaldoCaixa
		into #tmpCaixa
from dimLoteVenda a 
inner join fatFluxoCaixa b on a.IdLoteVenda = b.IdLoteVenda
left join dimTempo c on b.IdDataLoteVenda = c.IdTempo
group by a.IdLoteVenda, a.Lote, a.LoteUnico, a.Adquirente, c.DATA


-- Visão de venda vs realizado
select a.IdLoteVenda, Lote, a.LoteUnico, a.Adquirente, 
		count(b.IdTransacaoAdquirente) as QtdeTransacao, 
		sum(b.ValorBrutoAdquirente) as ValorBrutoAdquirente, 
		sum(b.ValorComissaoAdquirente) as ValorComissaoAdquirente, 
		sum(b.ValorLiquidoAdquirente) as Liquido, 
		sum(b.ValorCancelado) as ValorCancelado, 
		sum(b.ValorCanceladoLiquido) as ValorCanceladoLiquido, 
		sum(b.ValorChargeback) as ValorChargeback, 
		sum(b.ValorChargebackLiquido) as ValorChargebackLiquido,
		sum(b.ValorLiquidoAdquirente - isnull(b.ValorCanceladoLiquido, 0) - isnull(b.ValorChargebackLiquido, 0) + isnull(b.ValorEstornoLiquido, 0)) as Saldo
		into #tmpVenda
from dimLoteVenda a
inner join fatTransacaoAdquirente b on a.IdLoteVenda = b.IdLoteVenda
group by a.IdLoteVenda, Lote, a.LoteUnico, a.Adquirente
order by LoteUnico

-- Fazer o join com as tabelas tmp

-- Comparativo Venda vs Caixa (detalhe)
select	a.IdLoteVenda, a.Lote, a.LoteUnico, a.Adquirente, a.DATA, 
		a.ValorBrutoCaixa, b.ValorBrutoAdquirente, (a.ValorBrutoCaixa - b.ValorBrutoAdquirente) as diffBruto,
		a.ValorComissaoCaixa, b.ValorComissaoAdquirente, (a.ValorComissaoCaixa - b.ValorComissaoAdquirente) as diffComissao, 
		a.ValorLiquidoCaixa, b.Liquido, (a.ValorLiquidoCaixa - b.Liquido) as diffLiquido,
		a.CancelamentoLiquidoCaixa, b.ValorCanceladoLiquido,  (a.CancelamentoLiquidoCaixa - b.ValorCanceladoLiquido) as diffCancelamento,
		b.ValorCancelado, 
		a.ValorCBKLiquidoCaixa, b.ValorChargebackLiquido, (a.ValorCBKLiquidoCaixa - b.ValorChargebackLiquido) as diffCBK,
		b.ValorChargeback, 
		a.AntecipacaoCaixa, a.TaxaAntecipacaoCaixa, 
		a.ValorPrevistoCaixa, b.Saldo as ValorPrevistoVenda, (a.ValorPrevistoCaixa - b.Saldo) as diffPrevisto,
		a.ValorPagoCaixa, a.SaldoCaixa
from #tmpCaixa a
left join #tmpVenda b on a.IdLoteVenda = b.IdLoteVenda
order by a.DATA, a.LoteUnico, a.Lote

-- Comparativo Venda vs Caixa (por lote)
select	a.Lote, a.LoteUnico, a.Adquirente, 
		sum(a.ValorBrutoCaixa) as ValorBrutoCaixa, 
		sum(b.ValorBrutoAdquirente) as ValorBrutoAdquirente, 
		sum(a.ValorBrutoCaixa - b.ValorBrutoAdquirente) as diffBruto,
		sum(a.ValorComissaoCaixa) as ValorComissaoCaixa, 
		sum(b.ValorComissaoAdquirente) as ValorComissaoAdquirente, 
		sum(a.ValorComissaoCaixa - b.ValorComissaoAdquirente) as diffComissao, 
		sum(a.ValorLiquidoCaixa) as ValorLiquidoCaixa, 
		sum(b.Liquido) as LiquidoVenda, 
		sum(a.ValorLiquidoCaixa - b.Liquido) as diffLiquido,
		sum(a.CancelamentoLiquidoCaixa) as CancelamentoLiquidoCaixa, 
		sum(b.ValorCanceladoLiquido) as ValorCanceladoLiquido,  
		sum(a.CancelamentoLiquidoCaixa - b.ValorCanceladoLiquido) as diffCancelamento,
		sum(b.ValorCancelado) as ValorCancelado, 
		sum(a.ValorCBKLiquidoCaixa) as ValorCBKLiquidoCaixa, 
		sum(b.ValorChargebackLiquido) as ValorChargebackLiquido, 
		sum(a.ValorCBKLiquidoCaixa - b.ValorChargebackLiquido) as diffCBK,
		sum(b.ValorChargeback) as ValorChargeback, 
		sum(a.AntecipacaoCaixa) as AntecipacaoCaixa, 
		sum(a.TaxaAntecipacaoCaixa) as TaxaAntecipacaoCaixa, 
		sum(a.ValorPrevistoCaixa) as ValorPrevistoCaixa, 
		sum(b.Saldo) as ValorPrevistoVenda, 
		sum(a.ValorPrevistoCaixa - b.Saldo) as diffPrevisto,
		sum(a.ValorPagoCaixa) as ValorPagoCaixa, 
		sum(a.SaldoCaixa) as SaldoCaixa
from #tmpCaixa a
left join #tmpVenda b on a.IdLoteVenda = b.IdLoteVenda
group by a.LoteUnico, a.Lote, a.Adquirente
order by a.LoteUnico, a.Lote, a.Adquirente




select loteunico, count(Lote) from dimLoteVenda group by LoteUnico having count(Lote) > 1


select * from dimLoteVenda where LoteUnico in (171607450974060000,
171807450554062000,
171547450710060000,
171787450554062000)
order by LoteUnico



--select top 1000 * from dimTransacaoAdquirente

select * from dimTempo

select * from dsFluxoCaixa where LoteUnico = '171695120076957'

171531200038914
171531200039208
171531260216879
171531260216880
171531260218410
171531270203946
171531270203947
171531280165184

-- Comparativo entre valores brutos bate em 99,9% dos casos
select a.*, b.*
from #tmp a 
inner join (
		select --LoteUnico, Adquirente, DataLoteVenda 
					--,
					sum([ValorBruto]) as VlrBruto
				   ,sum([ValorComissao]) as [ValorComissao]
				   ,sum([VendasAntecCedidas]) as [VendasAntecCedidas]
				   ,sum([Cancelamentos]) as [Cancelamentos]
				   ,sum([Chargeback]) as [Chargeback]
				   ,sum([OutrosAjustes]) as [OutrosAjustes]
				   ,sum([ValorAntecipacoes]) as [ValorAntecipacoes]
				   ,sum([DescontosAntecCessoes]) as [DescontosAntecCessoes]
				   ,sum([ValorPrevisto]) as [ValorPrevisto]
				   ,sum([ValorPago]) as [ValorPago]
				   ,sum([Saldo]) as [Saldo]
				   ,sum([VendasCedidas]) as [VendasCedidas]
				   ,sum([CessoesAvulsas]) as [CessoesAvulsas]
				   ,sum([DescontosCessoesAvulsas]) as [DescontosCessoesAvulsas]
		from dsFluxoCaixa
		--where LoteUnico in ('171531200038914')
		group by LoteUnico, Adquirente, DataLoteVenda
		) b on a.LoteUnico = b.LoteUnico
--where a.LoteUnico in ('171531200038914')
order by a.DtCaptura, a.LoteUnico

select LoteUnico, Adquirente, DataLoteVenda 
			,sum([ValorBruto]) as VlrBruto
           ,sum([ValorComissao]) as [ValorComissao]
           ,sum([VendasAntecCedidas]) as [VendasAntecCedidas]
           ,sum([Cancelamentos]) as [Cancelamentos]
           ,sum([Chargeback]) as [Chargeback]
           ,sum([OutrosAjustes]) as [OutrosAjustes]
           ,sum([ValorAntecipacoes]) as [ValorAntecipacoes]
           ,sum([DescontosAntecCessoes]) as [DescontosAntecCessoes]
           ,sum([ValorPrevisto]) as [ValorPrevisto]
           ,sum([ValorPago]) as [ValorPago]
           ,sum([Saldo]) as [Saldo]
           ,sum([VendasCedidas]) as [VendasCedidas]
           ,sum([CessoesAvulsas]) as [CessoesAvulsas]
           ,sum([DescontosCessoesAvulsas]) as [DescontosCessoesAvulsas]
from dsFluxoCaixa
where LoteUnico in ('171531200038914')
group by LoteUnico, Adquirente, DataLoteVenda


select * from dsFluxoCaixa order by LoteUnico where LoteUnico = '17173401452448'
select a.*, b.ValorBrutoAdquirente, b.ValorBrutoIR, b.ValorCancelado, b.ValorChargeback  from dimTransacaoAdquirente a
inner join fatTransacaoAdquirente b on a.IdTransacaoAdquirente = b.IdTransacaoAdquirente
where LoteUnico = '17173401452448'

17173401452448


drop table #tmp

-- Visão de venda vs realizado
select LoteRO, a.LoteUnico, a.Adquirente, a.DtCaptura,  sum(b.ValorBrutoAdquirente) as ValorBrutoAdquirente, 
		sum(b.ValorComissaoAdquirente) as ValorComissaoAdquirente, 
		sum(b.ValorLiquidoAdquirente) as Liquido, 
		sum(b.ValorCancelado) as ValorCancelado, 
		sum(b.ValorCanceladoLiquido) as ValorCanceladoLiquido, 
		sum(b.ValorChargeback) as ValorChargeback, 
		sum(b.ValorChargebackLiquido) as ValorChargebackLiquido,
		sum(b.ValorLiquidoAdquirente - isnull(b.ValorCanceladoLiquido, 0) - isnull(b.ValorChargebackLiquido, 0) + isnull(b.ValorEstornoLiquido, 0)) as Saldo
		into #tmp
from dimTransacaoAdquirente a
inner join fatTransacaoAdquirente b on a.IdTransacaoAdquirente = b.IdTransacaoAdquirente
where a.DtCaptura between '6/1/2017' and '6/30/2017'
and a.LoteUnico in (select distinct [Lote Único] from dsMovimentoFinanceiro)
group by LoteRO, a.LoteUnico, a.Adquirente, a.DtCaptura
order by LoteUnico

select a.*, b.*
from #tmp a
inner join (
	-- Visão de movimento financeiro
	select [Lote Único] as LoteUnico,
			sum(isnull([Valor Bruto], 0)) as VlrBruto,  
			sum(isnull([Valor Comissão], 0)) as VlrComissao, 
			sum(isnull([Valor Líquido Previsto], 0)) as VlrLiquidoPrevisto, 
			sum(isnull([ValorLiquidoRealizado], 0)) as VlrLiquidoRealizado
	from dsMovimentoFinanceiro 
	group by [Lote Único]
) b on a.LoteUnico = b.LoteUnico


select		Data, 
			Adquirente, 
			sum(isnull([Valor Bruto], 0)) as VlrBruto,  
			sum(isnull([Valor Comissão], 0)) as VlrComissao, 
			sum(isnull([Valor Líquido Previsto], 0)) as VlrLiquidoPrevisto, 
			sum(isnull([ValorLiquidoRealizado], 0)) as VlrLiquidoRealizado
	from dsMovimentoFinanceiro 
	group by Data, 
			Adquirente 
	order by Data, Adquirente

select * from dsMovimentoFinanceiro where data = '6/1/2017' and Adquirente = 'Rede' and [Lote Único] = '1171291781235380'


select * from dimTransacaoAdquirente where LoteUnico = '17180793702576'
select * from fatTransacaoAdquirente where IdTransacaoAdquirente = 1376735





-- Visão de venda
select LoteRO, a.LoteUnico, a.Adquirente, a.DtCaptura,  sum(b.ValorBrutoAdquirente) as ValorBrutoAdquirente, 
		sum(b.ValorComissaoAdquirente) as ValorComissaoAdquirente, 
		sum(b.ValorLiquidoAdquirente) as Liquido, 
		sum(b.ValorCancelado) as ValorCancelado, 
		sum(b.ValorCanceladoLiquido) as ValorCanceladoLiquido, 
		sum(b.ValorChargeback) as ValorChargeback, 
		sum(b.ValorChargebackLiquido) as ValorChargebackLiquido,
		sum(b.ValorLiquidoAdquirente - isnull(b.ValorCanceladoLiquido, 0) - isnull(b.ValorChargebackLiquido, 0) + isnull(b.ValorEstornoLiquido, 0)) as Saldo
from dimTransacaoAdquirente a
inner join fatTransacaoAdquirente b on a.IdTransacaoAdquirente = b.IdTransacaoAdquirente
where a.LoteUnico in (select distinct [Lote Único] from dsMovimentoFinanceiro)
--where LoteUnico in (
--'171641220184540',
--'171645140258290',
--'171771290083391',
--'171771270179998',
--'171035110234223'
--)
group by LoteRO, a.LoteUnico, a.Adquirente, a.DtCaptura
order by LoteUnico

-- Visão de movimento financeiro
select [Lote Único],
		[Banco], 
		--[data],
		sum(isnull([Valor Bruto], 0)) as VlrBruto,  
		sum(isnull([Valor Comissão], 0)) as VlrComissao, 
		sum(isnull([Valor Líquido Previsto], 0)) as VlrLiquidoPrevisto, 
		sum(isnull([ValorLiquidoRealizado], 0)) as VlrLiquidoRealizado
from dsMovimentoFinanceiro 
--where [Lote Único] in (
--'171641220184540',
--'171645140258290',
--'171771290083391',
--'171771270179998',
--'171035110234223'
--)
group by [Lote Único],
		[Banco]--, [data]
order by [Lote Único]

select [Lote Único],
		[Banco], 
		[data],
		[Histórico], 
		sum(isnull([Valor Bruto], 0)) as VlrBruto,  
		sum(isnull([Valor Comissão], 0)) as VlrComissao, 
		sum(isnull([Valor Líquido Previsto], 0)) as VlrLiquidoPrevisto, 
		sum(isnull([ValorLiquidoRealizado], 0)) as VlrLiquidoRealizado
from dsMovimentoFinanceiro where [Lote Único] in (
'171641220184540'
)
group by [Lote Único],
		[Banco], [data], [Histórico] 
order by [Lote Único]

select * from dsMovimentoFinanceiro where [Lote Único] in ('171641220184540')
		

