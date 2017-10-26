use IR

--select top 1000 * from dimTransacaoAdquirente

select * from dsFluxoCaixa where LoteUnico is null

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
		

