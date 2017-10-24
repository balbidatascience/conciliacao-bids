use IR

select top 1000 * from dimTransacaoAdquirente

select LoteRO, a.LoteUnico, a.Adquirente, a.DtCaptura,  sum(b.ValorBrutoAdquirente) as ValorBrutoAdquirente, 
		sum(b.ValorComissaoAdquirente) as ValorComissaoAdquirente, 
		sum(b.ValorLiquidoAdquirente) as Liquido, 
		sum(b.ValorCancelado) as ValorCancelado, 
		sum(b.ValorChargeback) as ValorChargeback
from dimTransacaoAdquirente a
inner join fatTransacaoAdquirente b on a.IdTransacaoAdquirente = b.IdTransacaoAdquirente
where --LoteRO = '60111'
group by LoteRO, a.LoteUnico, a.Adquirente, a.DtCaptura




select * from dimTransacaoAdquirente where LoteRO = '60111'

select * from dimTransacaoAdquirente where LoteRO = '38531387'


