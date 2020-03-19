@AbapCatalog.sqlViewName: 'ZV_FLIGHTS_CDS'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS FLIGHTS'
@OData.publish: true
define view Z_FLIGHTS_CDS as select from spfli

association[0..*] to sflight as _flights
    on $projection.carrid = _flights.carrid and
       $projection.connid = _flights.connid 

association[0..*] to sbook as _bookings
    on $projection.carrid = _bookings.carrid and
       $projection.connid = _bookings.connid --and
//       $projection.fldate = to_bookings.fldate
{
    key spfli.carrid,
    key spfli.connid,
    spfli.countryfr,
    spfli.cityfrom,
    spfli.countryto,
    spfli.cityto,
    _flights,
    _bookings
}
