//
//  ViewController.h
//  GuardarDatosLEXcode
//
//  Created by Miguel Orzáez Joly on 26/11/13.
//  Copyright (c) 2013 MikiAirApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <NSXMLParserDelegate>
{    
    NSXMLParser *xmlParser;
    NSInteger profundidad;
    NSMutableString *nombreActual;
    NSString *claveActual;
    NSMutableDictionary *diccionarioDeContactos;
    NSMutableArray *arrayDeContactos;
}

@property (weak, nonatomic) IBOutlet UITextField *nombreTextField;
@property (weak, nonatomic) IBOutlet UITextField *apellidosTextField;
@property (weak, nonatomic) IBOutlet UITextField *telefonoTextField;

- (IBAction)guardarArrayPushButton:(id)sender;
- (IBAction)guardarFicheroPushButton:(id)sender;
- (IBAction)leerXMLPushButton:(id)sender;
- (IBAction)leerJSONPushButton:(id)sender;
- (IBAction)leerPlistPushButton:(id)sender;
@end
