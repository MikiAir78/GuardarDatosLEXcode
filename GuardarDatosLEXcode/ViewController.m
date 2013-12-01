//
//  ViewController.m
//  GuardarDatosLEXcode
//
//  Created by Miguel Orzáez Joly on 26/11/13.
//  Copyright (c) 2013 MikiAirApps. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    NSMutableArray *contactosAGuardar;
    NSMutableArray *contactos;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    contactosAGuardar = [[NSMutableArray alloc] init];
    contactos = [[NSMutableArray alloc] init];
    diccionarioDeContactos = [[NSMutableDictionary alloc] init];
    arrayDeContactos = [[NSMutableArray alloc] init];
    
    [self.nombreTextField setDelegate:self];
    [self.apellidosTextField setDelegate:self];
    [self.telefonoTextField setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - LecturaFicheros

-(void)leerFicheroPlist
{
    NSString *ruta = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *plistRuta = [ruta stringByAppendingPathComponent:@"Ejemplo.plist"];
    
    contactos = [NSMutableArray arrayWithContentsOfFile:plistRuta];
}

-(void)leerFicheroJson
{
    NSString *ruta = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *jsonRuta = [ruta stringByAppendingPathComponent:@"Ejemplo.json"];
    
    NSData *data = [[NSData alloc] initWithContentsOfFile:jsonRuta];
    
    contactos = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

#pragma mark - LecturaFicherosXML

-(void)examinarFicheroXML
{
    
    NSString *ruta = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *xml = [ruta stringByAppendingPathComponent:@"Ejemplo.xml"];

    
    NSString *xmlFile = [[NSString alloc] initWithContentsOfFile:xml encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"%@", xml);
    NSLog(@"%@", xmlFile);
    
    xmlParser = [[NSXMLParser alloc] initWithData:[xmlFile dataUsingEncoding:NSUTF8StringEncoding]];
    [xmlParser setDelegate:self];
    
    [xmlParser parse];
}

#pragma mark - NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    NSLog(@"Inicio de la lectura del xml", nil);
    profundidad = 0;
    claveActual = nil;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"Error: %@", [parseError localizedDescription]);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    claveActual = [elementName copy];
    
    if ([claveActual isEqualToString:@"contactos"] || [claveActual isEqualToString:@"contacto"])
    {
        [self showCurrentDepth];
        
        ++profundidad;
    }
    else
    {
        [self showCurrentDepth];
        nombreActual = [[NSMutableString alloc] init];
    }
    NSLog(@"Inicio Etiqueta: <%@>",claveActual);
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    // Vuelvo a asignarle el nombre a claveActual por si esta subiendo de nivel, para que copie el final de la etiqueta del nivel superior
    claveActual = [elementName copy];
    
    if ([elementName isEqualToString:@"contacto"] || [elementName isEqualToString:@"contactos"])
    {
        --profundidad;
    }
    else
    {
        NSLog(@"Elemento: %@", nombreActual);
    }
    NSLog(@"Fin Etiqueta: </%@>",claveActual);
    
    if ([elementName isEqualToString:@"contacto"])
    {
        [arrayDeContactos addObject:diccionarioDeContactos];
        diccionarioDeContactos = [[NSMutableDictionary alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if ([claveActual isEqualToString:@"nombre"] || [claveActual isEqualToString:@"apellidos"] || [claveActual isEqualToString:@"telefono"])
    {
        [nombreActual appendString:string];
        [diccionarioDeContactos setObject:nombreActual forKey:claveActual];
    }
    
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSLog(@"Fin de la lectura del xml", nil);
}

#pragma mark - IBAction

- (IBAction)guardarArrayPushButton:(id)sender
{
    NSMutableDictionary *contactoDictionary = [[NSMutableDictionary alloc] init];
    
    [contactoDictionary setObject:self.nombreTextField.text forKey:@"Nombre"];
    [contactoDictionary setObject:self.apellidosTextField.text forKey:@"Apellidos"];
    [contactoDictionary setObject:self.telefonoTextField.text forKey:@"Telefono"];
    
    [contactosAGuardar addObject:contactoDictionary];
    
    self.nombreTextField.text = @"";
    self.apellidosTextField.text = @"";
    self.telefonoTextField.text = @"";
}

- (IBAction)guardarFicheroPushButton:(id)sender {
    [self guardarDatosEnPlist];
    [self guardarDatosEnJson];
    [self guardarDatosEnXML];
}

- (IBAction)leerXMLPushButton:(id)sender {
    [self examinarFicheroXML];
    
    NSLog(@"\n\n Listado de todos los contactos:\n %@", arrayDeContactos);
}

- (IBAction)leerJSONPushButton:(id)sender {
    [self leerFicheroJson];
    
    NSLog(@"\n\n Listado de todos los contactos JSON:\n %@", contactos);
    
}

- (IBAction)leerPlistPushButton:(id)sender {
    [self leerFicheroPlist];
    
    NSLog(@"\n\n Listado de todos los contactos PLIST:\n %@", contactos);
}

#pragma mark - GuardarDatos

-(void)guardarDatosEnPlist
{
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:contactosAGuardar format:NSPropertyListBinaryFormat_v1_0 errorDescription:nil];
    
    NSString *ruta = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *ubicacionFichero = [ruta stringByAppendingPathComponent:@"Ejemplo.plist"];
    
    NSLog(@"%@",ubicacionFichero);
    
    [plistData writeToFile:ubicacionFichero atomically:YES];
}

-(void)guardarDatosEnJson
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:contactosAGuardar options:kNilOptions error:nil];
    NSString *ruta = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *ubicacionFichero = [ruta stringByAppendingPathComponent:@"Ejemplo.json"];
    
    [jsonData writeToFile:ubicacionFichero atomically:YES];
}


-(void)guardarDatosEnXML
{
    NSMutableString *xmlString = [[NSMutableString alloc] init];
    
    [xmlString appendString:@"<contactos>"];
    
    for (NSDictionary *contacto in contactosAGuardar)
    {
        [xmlString appendString:@"\n\t<contacto>"];
        [xmlString appendString:[NSString stringWithFormat:@"\n\t\t<nombre>%@</nombre>", [contacto objectForKey:@"Nombre"]]];
        [xmlString appendString:[NSString stringWithFormat:@"\n\t\t<apellidos>%@</apellidos>", [contacto objectForKey:@"Apellidos"]]];
        [xmlString appendString:[NSString stringWithFormat:@"\n\t\t<telefono>%@</telefono>", [contacto objectForKey:@"Telefono"]]];
        [xmlString appendString:@"\n\t</contacto>"];
    }
    
    [xmlString appendString:@"\n</contactos>"];
    
    NSString *ruta = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *ubicacionFichero = [ruta stringByAppendingPathComponent:@"Ejemplo.xml"];
    
    NSData *data = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
    
    [data writeToFile:ubicacionFichero atomically:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Private Methods
- (void)showCurrentDepth
{
    NSLog(@"Profundidad actual: %d", profundidad);
}
@end
