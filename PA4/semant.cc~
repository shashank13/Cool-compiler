

#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include "semant.h"
#include "utilities.h"


extern int semant_debug;
extern char *curr_filename;
extern ClassTable* classtable;
//////////////////////////////////////////////////////////////////////
//
// Symbols
//
// For convenience, a large number of symbols are predefined here.
// These symbols include the primitive type and method names, as well
// as fixed names used by the runtime system.
//
//////////////////////////////////////////////////////////////////////
static Symbol 
    arg,
    arg2,
    Bool,
    concat,
    cool_abort,
    copy,
    Int,
    in_int,
    in_string,
    IO,
    length,
    Main,
    main_meth,
    No_class,
    No_type,
    Object,
    out_int,
    out_string,
    prim_slot,
    self,
    SELF_TYPE,
    Str,
    str_field,
    substr,
    type_name,
    val;
//
// Initializing the predefined symbols.
//

static void initialize_constants(void)
{
    arg         = idtable.add_string("arg");
    arg2        = idtable.add_string("arg2");
    Bool        = idtable.add_string("Bool");
    concat      = idtable.add_string("concat");
    cool_abort  = idtable.add_string("abort");
    copy        = idtable.add_string("copy");
    Int         = idtable.add_string("Int");
    in_int      = idtable.add_string("in_int");
    in_string   = idtable.add_string("in_string");
    IO          = idtable.add_string("IO");
    length      = idtable.add_string("length");
    Main        = idtable.add_string("Main");
    main_meth   = idtable.add_string("main");
    //   _no_class is a symbol that can't be the name of any 
    //   user-defined class.
    No_class    = idtable.add_string("_no_class");
    No_type     = idtable.add_string("_no_type");
    Object      = idtable.add_string("Object");
    out_int     = idtable.add_string("out_int");
    out_string  = idtable.add_string("out_string");
    prim_slot   = idtable.add_string("_prim_slot");
    self        = idtable.add_string("self");
    SELF_TYPE   = idtable.add_string("SELF_TYPE");
    Str         = idtable.add_string("String");
    str_field   = idtable.add_string("_str_field");
    substr      = idtable.add_string("substr");
    type_name   = idtable.add_string("type_name");
    val         = idtable.add_string("_val");
}



ClassTable::ClassTable(Classes classes1) : semant_errors(0) , error_stream(cerr) {
    /* Fill this in */
	classes = classes1;
	this->install_basic_classes();
}

void ClassTable::install_basic_classes() {

    // The tree package uses these globals to annotate the classes built below.
   // curr_lineno  = 0;
    Symbol filename = stringtable.add_string("<basic class>");
    
    // The following demonstrates how to create dummy parse trees to
    // refer to basic Cool classes.  There's no need for method
    // bodies -- these are already built into the runtime system.
    
    // IMPORTANT: The results of the following expressions are
    // stored in local variables.  You will want to do something
    // with those variables at the end of this method to make this
    // code meaningful.

    // 
    // The Object class has no parent class. Its methods are
    //        abort() : Object    aborts the program
    //        type_name() : Str   returns a string representation of class name
    //        copy() : SELF_TYPE  returns a copy of the object
    //
    // There is no need for method bodies in the basic classes---these
    // are already built in to the runtime system.

    Class_ Object_class =
	class_(Object, 
	       No_class,
	       append_Features(
			       append_Features(
					       single_Features(method(cool_abort, nil_Formals(), Object, no_expr())),
					       single_Features(method(type_name, nil_Formals(), Str, no_expr()))),
			       single_Features(method(copy, nil_Formals(), SELF_TYPE, no_expr()))),
	       filename);

    // 
    // The IO class inherits from Object. Its methods are
    //        out_string(Str) : SELF_TYPE       writes a string to the output
    //        out_int(Int) : SELF_TYPE            "    an int    "  "     "
    //        in_string() : Str                 reads a string from the input
    //        in_int() : Int                      "   an int     "  "     "
    //
    Class_ IO_class = 
	class_(IO, 
	       Object,
	       append_Features(
			       append_Features(
					       append_Features(
							       single_Features(method(out_string, single_Formals(formal(arg, Str)),
										      SELF_TYPE, no_expr())),
							       single_Features(method(out_int, single_Formals(formal(arg, Int)),
										      SELF_TYPE, no_expr()))),
					       single_Features(method(in_string, nil_Formals(), Str, no_expr()))),
			       single_Features(method(in_int, nil_Formals(), Int, no_expr()))),
	       filename);  

    //
    // The Int class has no methods and only a single attribute, the
    // "val" for the integer. 
    //
    Class_ Int_class =
	class_(Int, 
	       Object,
	       single_Features(attr(val, prim_slot, no_expr())),
	       filename);
	
    //
    // Bool also has only the "val" slot.
    //
    Class_ Bool_class =
	class_(Bool, Object, single_Features(attr(val, prim_slot, no_expr())),filename);

    //
    // The class Str has a number of slots and operations:
    //       val                                  the length of the string
    //       str_field                            the string itself
    //       length() : Int                       returns length of the string
    //       concat(arg: Str) : Str               performs string concatenation
    //       substr(arg: Int, arg2: Int): Str     substring selection
    //       
    Class_ Str_class =
	class_(Str, 
	       Object,
	       append_Features(
			       append_Features(
					       append_Features(
							       append_Features(
									       single_Features(attr(val, Int, no_expr())),
									       single_Features(attr(str_field, prim_slot, no_expr()))),
							       single_Features(method(length, nil_Formals(), Int, no_expr()))),
					       single_Features(method(concat, 
								      single_Formals(formal(arg, Str)),
								      Str, 
								      no_expr()))),
			       single_Features(method(substr, 
						      append_Formals(single_Formals(formal(arg, Int)), 
								     single_Formals(formal(arg2, Int))),
						      Str, 
						      no_expr()))),
	       filename);
    
    Class_ Self_type_class = 
            class_(idtable.add_string("SELF_TYPE"), Object, nil_Features(),filename);
    
	this->object_ptr = dynamic_cast<class__class*>(Object_class);
	this->bool_const_ptr = dynamic_cast<class__class*>(Bool_class);
    this->int_const_ptr = dynamic_cast<class__class*>(Int_class);
    this->str_const_ptr = dynamic_cast<class__class*>(Str_class);
    this->self_type_ptr = dynamic_cast<class__class*>(Self_type_class);
	classes = append_Classes(classes,single_Classes(Object_class)); 
	classes = append_Classes(classes,single_Classes(IO_class)); 
	classes = append_Classes(classes,single_Classes(Int_class)); 
	classes = append_Classes(classes,single_Classes(Bool_class)); 
	classes = append_Classes(classes,single_Classes(Str_class));
}

////////////////////////////////////////////////////////////////////
//
// semant_error is an overloaded function for reporting errors
// during semantic analysis.  There are three versions:
//
//    ostream& ClassTable::semant_error()                
//
//    ostream& ClassTable::semant_error(Class_ c)
//       print line number and filename for `c'
//
//    ostream& ClassTable::semant_error(Symbol filename, tree_node *t)  
//       print a line number and filename
//
///////////////////////////////////////////////////////////////////

ostream& ClassTable::semant_error(Class_ c)
{                                                             
    return semant_error(c->get_filename(),c);
}    

ostream& ClassTable::semant_error(Symbol filename, tree_node *t)
{
    error_stream << filename << ":" << t->get_line_number() << ": ";
    return semant_error();
}

ostream& ClassTable::semant_error()                  
{                                                 
    semant_errors++;                            
    return error_stream;
} 
Symbol class__class::get_name() {
	return this->name;
}

Symbol class__class::get_parent() {
	return this->parent;
}
/*
	Following part is Inheritance checking
*/
Type ClassTable::get_class(const char* name)
{
	if (class_name_map.find(name) == class_name_map.end()) return NULL;
	return class_name_map[name];
}
bool ClassTable::map_name_to_class()
{
	class_name_map.clear();
	/* map class_name to class*, using dynamic_cast to get the constructor class of Class */
	for (int i = classes->first(); classes->more(i); i = classes->next(i))
	{
		class__class* it = dynamic_cast<class__class*>(classes->nth(i));
		if (it == NULL) {
			semant_error(it) << "dynamic_cast error! at class\n";
			return false;
		}
        class_name_map[it->get_name()->get_string()] = it;
	}
    class_name_map["SELF_TYPE"] = this->self_type_ptr;
	return true;
}
bool ClassTable::inheritance_loop_search(class__class *it, class__class *start,int loopID)
{
	while (it != object_ptr && it->visID == 0)
	{
        printf("it = %s, it->parent = %s\n",it->get_name()->get_string(), it->father->get_name()->get_string());
		it->visID = loopID;
		if (it->father->visID == loopID) {
			return false;
		}
		it = it->father;
	}
	return true;
}
bool ClassTable::inheritance_check()
{
	for (int i = classes->first(); classes->more(i); i = classes->next(i))
	{
		class__class* it = dynamic_cast<class__class*>(classes->nth(i));
		if (it == object_ptr) continue;		
        if (class_name_map.find(it->get_parent()->get_string()) == class_name_map.end()) {
			semant_error(it) << "class " << it->get_name() << " instantiate from undefined class\n";
			return false;
		}
        it->father = class_name_map[it->get_parent()->get_string()];
		it->visID = 0;
	}
	int loopID = 0;
	for (int i = classes->first(); classes->more(i); i = classes->next(i))
	{
		class__class* it = dynamic_cast<class__class*>(classes->nth(i));
		if (it->visID == 0) {
			if (!inheritance_loop_search(it, it, ++loopID)) {
				semant_error(it) << "inheritance loop exist!\n";
				return false;
			}
		}
	}
	return true;
}
/*
	Following part find method signature by (class, method_name) 
*/
bool class__class::is_subclass(Type T1)
{
    class__class* it = this;
    if (T1 == classtable->object_ptr) return true;
    for (it = this; it != classtable->object_ptr; it = it->father) 
    {   
        if (it == T1) return true;
    }
    return false;
}
Type class__class::least_upper_bound(Type T1)
{
    class__class* it = this;
    std::vector<Type> father0, father1;
    for (it = this; it != classtable->object_ptr; it = it->father) 
        father0.push_back(it);
    father0.push_back(classtable->object_ptr);
    for (it = T1; it != classtable->object_ptr; it = it->father) 
        father1.push_back(it);
    father1.push_back(classtable->object_ptr);
    
    for (int i=father0.size()-1, j=father1.size()-1;i >= 0 && j >= 0;i--, j--) 
    {
        if (father0[i] != father1[j]) {
            return father0[i+1];
        }
    }
    return father0[0];
}

bool class__class::find_method(const char* method_name, std::vector<class__class*> &parameter_list)
{
	for (int i = features->first(); features->more(i); i = features->next(i))
	{
		method_class* it = dynamic_cast<method_class*>(features->nth(i));
		if (it != NULL)
		{
			if (it->find_method(method_name, parameter_list))
				return true;
		}
	}
	if (this != classtable->object_ptr)
		return this->father->find_method(method_name, parameter_list);
	else
		return false;
}
bool method_class::find_method(const char* method_name, std::vector<class__class*> &parameter_list)
{
	if (strcmp(method_name, this->name->get_string()) != 0) return false;
	for (int i = formals->first(); formals->more(i); i = formals->next(i))
	{
		formal_class* it = dynamic_cast<formal_class*>(formals->nth(i));
		if (it != NULL)
		{
			if (!it->find_method(method_name, parameter_list))
				return false;
		}else
		{
			cerr << "formal dynamic_cast error!\n";
			return false;
		}
	}
	class__class *it = classtable->get_class(return_type->get_string());
	if (it == NULL) {
		return false;
	}
	cout << "return_type->get_string() = " << return_type->get_string() << "\n";
	parameter_list.push_back(it);
	return true;	
}
bool formal_class::find_method(const char* method_name, std::vector<class__class*> &parameter_list)
{
	cout << "type = " << type_decl->get_string() << "\n";
	class__class* it = classtable->get_class(type_decl->get_string());
	if (it == NULL) {
		printf("formal class Not found");
		return false;
	}
	parameter_list.push_back(it);
	return true;
}
/*
	Typechecking
*/
Symbol attr_class::get_name() {
    return this->name;
}
Symbol method_class::get_name() {
    return this->name;
}
void class__class::gather_attribute(Symbol_Table *symboltable,class__class* class_ptr)
{
    if (this == classtable->object_ptr) return;
    this->father->gather_attribute(symboltable, class_ptr);
    symboltable->enterscope();
    for (int i = features->first(); features->more(i); i = features->next(i)) 
    {
        attr_class *it = dynamic_cast<attr_class*>(features->nth(i));
        if (it != NULL) {
            it->type_check(symboltable, class_ptr);
        }
    }
}
Type class__class::type_check(Symbol_Table *symboltable, class__class *class_ptr)
{
    if (this == classtable->object_ptr) return this;
	std::map<const char*, int> method_map;
    this->father->gather_attribute(symboltable, class_ptr);
    symboltable->enterscope();
    symboltable->addid(idtable.add_string("self"), classtable->self_type_ptr);
    for (int i = features->first(); features->more(i); i = features->next(i))
	{
		method_class *it = dynamic_cast<method_class*>(features->nth(i));
		if (it != NULL)
            method_map[it->get_name()->get_string()]++;
		else
		{
			attr_class *it = dynamic_cast<attr_class*>(features->nth(i));
            it->type_check(symboltable, class_ptr);
        }
	}
	for (std::map<const char*, int>::iterator it = method_map.begin(); it != method_map.end(); it++)
	{
		if (it->second > 1)
			classtable->semant_error(class_ptr) << "method " << it->first << " appeals multiple times\n";
	}
    for (int i = features->first(); features->more(i); i = features->next(i))
	{
        method_class *it = dynamic_cast<method_class*>(features->nth(i));        
		if (it != NULL) it->type_check(symboltable, class_ptr);
	}
    symboltable->exitscope();
    return this;
}
Type attr_class::type_check(Symbol_Table* symboltable, class__class* class_ptr)
{
    Type T0 = classtable->get_class(this->type_decl->get_string());
    if (T0 == NULL) {
        classtable->semant_error(class_ptr) << " Attribute type doesn't exist\n";
        return classtable->object_ptr;
    }
    if (symboltable->probe(this->name) != NULL) {
        classtable->semant_error(class_ptr) << " Attribute " << this->name << " already exist\n";        
        return classtable->object_ptr;
    }
    /* means no initialization at all */
    if (dynamic_cast<no_expr_class*>(this->init) != NULL) {
        symboltable->addid(this->name, T0);    
        return T0;
    }
    Type T1 = this->init->type_check(symboltable, class_ptr);
    if (!T1->is_subclass(T0)) {
        classtable->semant_error(class_ptr) << " Initialization type not conformed to definition\n";       
        symboltable->addid(this->name, classtable->object_ptr);        
        return classtable->object_ptr;
    }
    symboltable->addid(this->name, T0);    
    return T0;
}
Type method_class::type_check(Symbol_Table* symboltable, class__class* class_ptr)
{
    symboltable->enterscope();
    for (int i = this->formals->first(); this->formals->more(i); i = this->formals->next(i))
    {
        this->formals->nth(i)->type_check(symboltable, class_ptr);
    }
    this->expr->type_check(symboltable, class_ptr);
    if (classtable->get_class(this->return_type->get_string()) == NULL) {
        classtable->semant_error(class_ptr) << "method return type doesn't exist\n";
        return classtable->object_ptr;
    }
    symboltable->exitscope();
}
Type formal_class::type_check(Symbol_Table *symboltable, class__class *class_ptr)
{
    if (symboltable->probe(this->name) != NULL) {
        classtable->semant_error(class_ptr) << "formal " << this->name << " already declared in this scope\n";
        return classtable->object_ptr;
    }
    if (strcmp(this->name->get_string(), "self") == 0) {
        classtable->semant_error(class_ptr) << "formal cannot be self\n";
        symboltable->addid(this->name, classtable->object_ptr);
        return classtable->object_ptr;
    }
    if (classtable->get_class(this->type_decl->get_string()) == NULL) {
        classtable->semant_error(class_ptr) << " formal type doesn't exist\n";
        symboltable->addid(this->name, classtable->object_ptr);
        return classtable->object_ptr;
    }
    Type T = classtable->get_class(this->type_decl->get_string());
    symboltable->addid(this->name, T);
    return T;
}
Type object_class::type_check(Symbol_Table* symboltable, class__class* class_ptr)
{
    Type T;
    if ((T = symboltable->lookup(this->name)) == NULL) {
        classtable->semant_error(class_ptr) << this->name << " not defined\n";
        return this->set_type(classtable->object_ptr);
    }
    return T;
}
Type assign_class::type_check(Symbol_Table* symboltable, class__class* class_ptr)
{
    Type T1 = symboltable->lookup(this->name) ;
    if (T1 == NULL) T1 = classtable->object_ptr;
    Type T2 = this->expr->type_check(symboltable, class_ptr);
    if (!T2->is_subclass(T1)) {
        classtable->semant_error(class_ptr) << "assign error " << T2->get_name() << " not conform " << T1->get_name();
        return this->set_type(classtable->object_ptr);
    }
    return this->set_type(T2);
}
Type bool_const_class::type_check(Symbol_Table* symboltable, class__class* class_ptr)
{
    return this->set_type(classtable->bool_const_ptr);
}
Type int_const_class::type_check(Symbol_Table* symboltable, class__class* class_ptr)
{
    return this->set_type(classtable->int_const_ptr);
}
Type string_const_class::type_check(Symbol_Table* symboltable, class__class* class_ptr)
{
    return this->set_type(classtable->str_const_ptr);
}
Type new__class::type_check(Symbol_Table* symboltable, class__class* class_ptr)
{
    return this->set_type(classtable->get_class(this->type_name->get_string()));
}
Type dispatch_class::type_check(Symbol_Table* symboltable, class__class* class_ptr)
{
    Type T0 = this->expr->type_check(symboltable, class_ptr);
    if (T0 == classtable->self_type_ptr) T0 = class_ptr;
    
    std::vector<Type> formal_list;
    if (!T0->find_method(this->name->get_string(), formal_list)) {
        classtable->semant_error(class_ptr) << "method " << this->name << " not found\n" << endl;
        return classtable->object_ptr;
    }
    int j = 0;
    for (int i = actual->first(); actual->more(i); i = actual->next(i), j++)
    {
        Type Ti = actual->nth(i)->type_check(symboltable, class_ptr);
        
        if (!Ti->is_subclass(formal_list[j]))  {
            classtable->semant_error(class_ptr) << "when dispatch " << this->name << " parameter " << j << " not conform formal type\n";
            return classtable->object_ptr;
        }
    }
    if (j != (int)formal_list.size()-1) {
        classtable->semant_error(class_ptr) << "when dispatch " << this->name << " parameter numbers didn't match\n";
        return classtable->object_ptr;
    }
    Type return_type = (formal_list[j] == classtable->self_type_ptr) ? T0 : formal_list[j];
    return this->set_type(return_type);
}
Type static_dispatch_class::type_check(Symbol_Table* symboltable, class__class* class_ptr)
{
    Type T0 = this->expr->type_check(symboltable, class_ptr);
    if (T0 == classtable->self_type_ptr) T0 = class_ptr;
    Type T = classtable->get_class(this->type_name->get_string());
    if (T == NULL) {
        classtable->semant_error(class_ptr) << "static dispatch class undefined\n";
        return this->set_type(classtable->object_ptr);
    }
    if (!T0->is_subclass(T)) {
        classtable->semant_error(class_ptr) << "in static dispatch expr not conform static class\n";
        return this->set_type(classtable->object_ptr);
    }
    std::vector<Type> formal_list;
    if (!T->find_method(this->name->get_string(), formal_list)) {
        classtable->semant_error(class_ptr) << "method " << this->name << " not found\n" << endl;
        return classtable->object_ptr;
    }
    int j = 0;
    for (int i = actual->first(); actual->more(i); i = actual->next(i), j++)
    {
        Type Ti = actual->nth(i)->type_check(symboltable, class_ptr);
        if (!Ti->is_subclass(formal_list[j]))  {
            classtable->semant_error(class_ptr) << "when dispatch " << this->name << " parameter " << j << " not conform formal type\n";
            return classtable->object_ptr;
        }
    }
    if (j != formal_list.size()-1) {
        classtable->semant_error(class_ptr) << "when dispatch " << this->name << " parameter numbers didn't match\n";
        return classtable->object_ptr;
    }
    Type return_type = (formal_list[j] == classtable->self_type_ptr) ? T0 : formal_list[j];
    return this->set_type(return_type);
}
Type cond_class::type_check(Symbol_Table *symboltable, class__class *class_ptr)
{
    this->pred->type_check(symboltable, class_ptr);
    Type T2 = this->then_exp->type_check(symboltable, class_ptr);
    Type T3 = this->else_exp->type_check(symboltable, class_ptr);
    return this->set_type(T2->least_upper_bound(T3));
}
Type block_class::type_check(Symbol_Table *symboltable, class__class *class_ptr)
{
    Type T;
    for (int i = this->body->first(); this->body->more(i); i = this->body->next(i))
    {
        T = this->body->nth(i)->type_check(symboltable, class_ptr);
    }
    return this->set_type(T);
}
Type let_class::type_check(Symbol_Table *symboltable, class__class *class_ptr)
{
    Type T0 = this->type_decl->get_string() == "SELF_TYPE" ? class_ptr : 
                                                             classtable->get_class(this->type_decl->get_string());
    if (T0 == NULL) {
        classtable->semant_error(class_ptr) 
                << " in let type " << type_decl << " is not exist\n";
        return this->set_type(classtable->object_ptr);
    }
    
    Type T1 = this->init->type_check(symboltable, class_ptr);
    if (dynamic_cast<no_expr_class*>(this->init) != NULL
            || T1->is_subclass(T0)) {
        symboltable->enterscope();
        symboltable->addid(this->identifier, T0);
        Type T2 = this->body->type_check(symboltable, class_ptr);
        symboltable->exitscope();
        return this->set_type(T2);
    }else
    {
        classtable->semant_error(class_ptr) 
                << " in let type " << type_decl << " is not conformed by initialization\n";
        return this->set_type(classtable->object_ptr);
    }
}
Type typcase_class::type_check(Symbol_Table *symboltable, class__class *class_ptr)
{
    this->expr->type_check(symboltable, class_ptr);
    Type T;
    for (int i = this->cases->first(); this->cases->more(i); i = this->cases->next(i))
    {
        Type Ti = this->cases->nth(i)->type_check(symboltable, class_ptr);
        T = T->least_upper_bound(Ti);
    }
    return T;
}
Type branch_class::type_check(Symbol_Table *symboltable, class__class *class_ptr)
{
    symboltable->enterscope();
    Type T0 = classtable->get_class(this->type_decl->get_string());
    if (T0 == NULL) {
        classtable->semant_error(class_ptr) 
                << " in branch type " << type_decl << " not exist\n";
        return classtable->object_ptr;
    }
    symboltable->addid(this->name, T0);
    Type T1 = this->expr->type_check(symboltable, class_ptr);
    symboltable->exitscope();
    return T1;
}
Type loop_class::type_check(Symbol_Table *symboltable, class__class *class_ptr)
{
    Type T1 = this->pred->type_check(symboltable, class_ptr);
    if (T1 != classtable->bool_const_ptr) {
        classtable->semant_error(class_ptr) << "loop pred is not Bool\n";
    }
    this->body->type_check(symboltable, class_ptr);
    return this->set_type(classtable->object_ptr);
}
Type isvoid_class::type_check(Symbol_Table *symboltable, class__class *class_ptr)
{
    this->e1->type_check(symboltable, class_ptr);
    return this->set_type(classtable->bool_const_ptr);
}
Type comp_class::type_check(Symbol_Table *symboltable, class__class *class_ptr)
{
    if (this->e1->type_check(symboltable, class_ptr) != classtable->bool_const_ptr)
    {
        classtable->semant_error(class_ptr) << "not expression is not bool\n";
    }
    return this->set_type(classtable->bool_const_ptr);
}
Type lt_class::type_check(Symbol_Table *symboltable, class__class *class_ptr)
{
    if (this->e1->type_check(symboltable, class_ptr) != classtable->int_const_ptr
            ||  this->e2->type_check(symboltable, class_ptr) != classtable->int_const_ptr) {
        classtable->semant_error(class_ptr) << "< expression is not int\n";
    }
    return this->set_type(classtable->bool_const_ptr);
}
Type leq_class::type_check(Symbol_Table *symboltable, class__class *class_ptr)
{
    if (this->e1->type_check(symboltable, class_ptr) != classtable->int_const_ptr
            ||  this->e2->type_check(symboltable, class_ptr) != classtable->int_const_ptr) {
        classtable->semant_error(class_ptr) << "<= expression is not int\n";
    }
    return this->set_type(classtable->bool_const_ptr);
}
Type neg_class::type_check(Symbol_Table *symboltable, class__class *class_ptr)
{
    if (this->e1->type_check(symboltable, class_ptr) != classtable->int_const_ptr) {
        classtable->semant_error(class_ptr) << "Neg expression is not int\n";
    }
    return this->set_type(classtable->bool_const_ptr);
}
Type plus_class::type_check(Symbol_Table *symboltable, class__class *class_ptr)
{
    if (this->e1->type_check(symboltable, class_ptr) != classtable->int_const_ptr
            ||  this->e2->type_check(symboltable, class_ptr) != classtable->int_const_ptr) {
        classtable->semant_error(class_ptr) << " plus expression is not int\n";
    }
    return this->set_type(classtable->int_const_ptr);
}
Type sub_class::type_check(Symbol_Table *symboltable, class__class *class_ptr)
{
    if (this->e1->type_check(symboltable, class_ptr) != classtable->int_const_ptr
            ||  this->e2->type_check(symboltable, class_ptr) != classtable->int_const_ptr) {
        classtable->semant_error(class_ptr) << " sub expression is not int\n";
    }
    return this->set_type(classtable->int_const_ptr);
}
Type mul_class::type_check(Symbol_Table *symboltable, class__class *class_ptr)
{
    if (this->e1->type_check(symboltable, class_ptr) != classtable->int_const_ptr
            ||  this->e2->type_check(symboltable, class_ptr) != classtable->int_const_ptr) {
        classtable->semant_error(class_ptr) << " mul expression is not int\n";
    }
    return this->set_type(classtable->int_const_ptr);
}
Type divide_class::type_check(Symbol_Table *symboltable, class__class *class_ptr)
{
    if (this->e1->type_check(symboltable, class_ptr) != classtable->int_const_ptr
            ||  this->e2->type_check(symboltable, class_ptr) != classtable->int_const_ptr) {
        classtable->semant_error(class_ptr) << " divide expression is not int\n";
    }
    return this->set_type(classtable->int_const_ptr);
}
Type eq_class::type_check(Symbol_Table *symboltable, class__class *class_ptr)
{
    Type T1 = this->e1->type_check(symboltable, class_ptr);
    Type T2 = this->e2->type_check(symboltable, class_ptr);
    if (T1 == classtable->bool_const_ptr || T1 == classtable->int_const_ptr ||
            T1 == classtable->str_const_ptr || T2 == classtable->bool_const_ptr
            || T2 == classtable->int_const_ptr || T2 == classtable->str_const_ptr)
    {
        if (T1 != T2) {
            classtable->semant_error(class_ptr) << " equal expression is not the same type\n";
        }
    }
    return this->set_type(classtable->bool_const_ptr);
}
Type no_expr_class::type_check(Symbol_Table *symboltable, class__class *class_ptr)
{
	return classtable->object_ptr;
}
void ClassTable::type_check()
{
	for (int i = classes->first(); classes->more(i); i = classes->next(i))
	{
		Symbol_Table* symboltable = new Symbol_Table();
        Type it = dynamic_cast<Type>(classes->nth(i));
        it->type_check(symboltable, it);
		free(symboltable); 
	}
}
/*   This is the entry point to the semantic checker.

     Your checker should do the following two things:

     1) Check that the program is semantically correct
     2) Decorate the abstract syntax tree with type information
        by setting the `type' field in each Expression node.
        (see `tree.h')

     You are free to first do 1), make sure you catch all semantic
     errors. Part 2) can be done in a second stage, when you want
     to build mycoolc.
 */
void ClassTable::test() 
{
	for (int i = classes->first(); classes->more(i); i = classes->next(i))
	{
		class__class* it = dynamic_cast<class__class*>(classes->nth(i));
		std::vector<class__class*> parameter_list;
		//cout << it->get_name() << " " << it->find_method("foo", parameter_list) << " ";
		//cout << "para_size = " << parameter_list.size() << endl;
		if (it->find_method("foo", parameter_list))
		{
			for (int j = 0; j < (int)parameter_list.size(); j++)
			{
				cout << "signature = " << parameter_list[j]->get_name() << endl;
			}
		}
		//it->type_check();
	}
}
void program_class::semant()
{
    initialize_constants();
	
    /* ClassTable constructor may do some semantic analysis */
    classtable = new ClassTable(classes);
	
    /* some semantic analysis code may go here */
	classtable->map_name_to_class();
	classtable->inheritance_check();
	
    if (classtable->errors()) {
	cerr << "Compilation halted due to static semantic errors." << endl;
	exit(1);
    }
    
    classtable->test();
    exit(1);
    
    classtable->type_check();
}



